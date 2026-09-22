library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
 entity VZ300 is
	Port( --Here we define all Inputs and outputs to the FPGA
		CLK     : in  std_logic; --Z80 clock, we use this to clock the SD card and power the SPI shift register
		Address        : in  std_logic_vector(15 downto 0); --Address bus
		D        : inout  std_logic_vector(7 downto 0);--Data bus - InOut means it is bidirectional.
		RD_N     : in  std_logic;
		WR_N     : in  std_logic;
		IOREQ		: in std_logic;
		MEMREQ		: in std_logic;
		NMI : in std_logic; --Not used in this design but the default unused fpga pin is set to output, driving high which would be bad
		M1 : in std_logic; --Likewise
		RESET : in std_logic; --Used to reset some of the latches and buffers used in the design. RAM bank and EPROM Enable for example.

		DataDIR : out std_logic; --Sets the Level Converters data direction, in to FPGA or Out to Z80 bus.
		OE_N : out std_logic; --Used to enable or disable the output of the level converters. We didn't need to route this signal.
		
		SRAM_CS : out std_logic; --SRAM WE and RD are tied to Z80 bus signals. The CS is used to select or deselect the RAM at appropriate address space
		EPROM_CS : out std_logic; --EPROM RD is tied to the z80 bus. The CS is used to select or deselect the EPROM as needed
		SA16      : out std_logic; --This is the SRAM Address line A16. We can toggle this though a port to set which half of the IC to use
		
		LED1 : out std_logic;

		SD_I : in std_logic;
		SD_O : out std_logic;
		SD_CS : out std_logic;
		SD_CLK : out std_logic;
		SD_Card : in std_logic --An input used to detect if the SD is inserted. We probably won't be using this but its here just incase
	);
end entity VZ300;
 
architecture Behavioral of VZ300 is  --Here we create Signals. These can be considered as wires joining logic together. Signals can also be latches.

signal LED1buff : std_logic;

signal PortSDconfigOut : std_logic;
signal PortSDin : std_logic;
signal PortSDout : std_logic;
signal PortMapperOut : std_logic;
signal PortRAMmapOut : std_logic;

----------------Address decoding signals
signal DOSarea8k : std_logic; --A signal which is active when address space is in the 8k DOS cart area.
signal DOSarea2k : std_logic; --A signal which is active when address space is in the 2k DOS cart area above the 8K ROM area
signal RAMarea200 : std_logic;   --A signal which is active when address space is equal or greater than $7800-9000. This is user and expanded ram areas in VZ200
signal RAMarea300 : std_logic;   --A signal which is active when address space is equal or greater than $7800-B800. This is user and expanded ram areas in VZ300
signal RAMarea : std_logic;		--Gate of 200 or 300 areas depending on the register VZmap value
----------------Config signals
signal EPROM_Selected : std_logic; --A signal which will map SRAM or EPROM into the DOSarea2k
signal SRAM_BankHi	:	std_logic;	--A signal to select the upper address bit of the SRAM when A15='1', effectively the SRAM Bank bit of the expanded ram
signal SRAM_BankLo  	:	std_logic;	--A signal to select the upper address bit of the SRAM when A15='0', effictively the SRAM bank bit of the DOS ROM area
signal VZmap		: std_logic;	--A signal to use VZ200 or VZ300 mapping. 0=200.

---------------SPI Signals
signal SPIinBuffer  : std_logic_vector (7 downto 0);

signal SPIoutBuffer : std_logic_vector (7 downto 0);
signal SPIBuffer		: std_logic_vector (7 downto 0);
signal SPIclkCount  : std_logic_vector (3 downto 0):="0000"; 
signal SPIclkEn	  : std_logic:='0';
signal SPISDcs		  : std_logic:='1';
signal SPI_bank_clk  : std_logic;
signal SPI_bank_Buff_clk : std_logic;
signal SPI_Readback_clk : std_logic;
signal SPItrigger : std_logic;
signal SPICLOCK : std_logic;
signal SPIclkSpeed : std_logic;
signal SD_Or : std_logic;
signal SPIAddressAccess : std_logic:='1';
signal State : std_logic_vector(1 downto 0);
signal CLKPreScale : std_logic_vector(7 downto 0);
signal Start : std_logic;


--------Constants
constant MapperPortNumber : integer := 55;
constant SDcfgPortNumber : integer := 56;
constant SDioPortNumber : integer := 57;
constant RAMmapPortNumber : integer := 58;

begin



-----------------------------------------------------------------------
-- Signal Assignments
-----------------------------------------------------------------------

DataDir<=not(RD_N) when PortSDIn='0' else '0';	--Level Converters data direction is from the FPGA to Z80 when z80_RD is asserted or reading from the SD register
	
OE_N<='0'; --Level Converter data OE, always active.	

EPROM_CS<=MEMREQ when DOSarea8k ='0' and EPROM_Selected='0' else '1'; --EPROM is enabled when a read from DOSarea8k is requested AND EPROM_Selected is enabled.
 
SA16 <= SRAM_BankHi when Address(15)='1' else SRAM_BankLo;
 
LED1 <= LED1buff;

SRAM_CS<=MemREQ when RAMarea='0' or DOSarea2k='0' or WR_N='0' or (DOSarea8k='0' and EPROM_Selected='1') else '1'; 

RAMarea<=RAMarea200 when VZmap='0' else RAMarea300;

--SRAM is enable when:
-- 	Memreq=Low and 
--				either RAMarea or Dosarea2k is selected OR
--				if ANY address WRITE is detected. This allows us to write to the RAM at DOSarea8k while EPROM is still enabled.
--
--		SRAM is also enabled if EPROM_Selected='0' and the read is in the Dosarea8k region.

----------------
---Port Decoding
----------------


PortSDconfigOut <= '0' 	when IOREQ='0' and WR_N = '0' and Address(7 downto 0) = SDcfgPortNumber else '1';
PortSDOut <= '0' 		when IOREQ='0' and WR_N = '0' and Address(7 downto 0) = SDioPortNumber else '1';
PortSDIn <= '0' 		when IOREQ='0' and RD_N = '0' and Address(7 downto 0) = SDioPortNumber else '1';
PortMapperOut <= '0' when IOREQ='0' and WR_N = '0' and Address(7 downto 0) = MapperPortNumber else '1';
PortRAMmapOut <= '0' when IOREQ='0' and WR_N = '0' and Address(7 downto 0) = RAMmapPortNumber else '1';

-------------------
--Address Decoding-
-------------------

DOSarea8k <= '0' when (Address > x"3FFF" ) and (Address < x"6000") else '1'; -- 4000-5FFF 
DOSarea2k <= '0' when (Address > x"5FFF" ) and (Address < x"6800") else '1'; -- 6000-67FF  
RAMarea300   <= '0' when (Address > x"B7FF" ) else '1'; --B800 or higher 
RAMarea200   <= '0' when (Address > x"8FFF" ) else '1'; --9000 or higher 

-----------------------------------------------------------------------
-- Clock Generation
-----------------------------------------------------------------------
--All mappers common addresses

process (PortSDin,RD_N,memreq)
begin
	if PortSDin='0' then
		D<=SPIinBuffer;
	else
	D<="ZZZZZZZZ"; --Setting a InOut port to Z means high impedance input. Anything else would set it as an output.
	end if;
end process;
	
 
process (PortMapperOut,reset) --The signals in the process list can be considered the events which trigger the process. i.e. any change to PortMapperOut or Reset 
begin
	if Reset='0' then	
		EPROM_Selected<='0';  --If z80 reset then enable EPROM and set bank 0
		SRAM_BankLo<='0';
		SRAM_BankHi<='0';
	else
		
	if rising_edge(PortMapperOut) then	
				EPROM_Selected <= D(0);
				SRAM_BankLo<= D(1);
				SRAM_BankHi<= D(2);
				LED1buff<=D(3);
		end if;
	end if;
end process; 

process (PortRAMmapOut,reset)
begin
	if Reset='0' then	
		VZmap<='0';  --If z80 reset then enable EPROM and set bank 0
	else
		
	if rising_edge(PortRAMmapOut) then	
				VZmap <= D(0);
		end if;
	end if;
end process; 


process (PortSDconfigOut)
begin
	
	if rising_edge(PortSDconfigOut) then	
				SPIclkSpeed <= D(0); -- Low or High speed clock mode for SPI
				SPIsdCS <= D(1);
		end if;
end process;
  
process (PortSDOut,state)
begin
	if state>0 then Start<='0'; 
		else
			if rising_edge(PortSDout) then	
				SPIoutBuffer <= D;
				Start<= '1';
		end if;
	end if;
end process;
  
---------------------------
--SPI Code here:
---------------------------
SPIclock<=CLKprescale(7) when SPIclkSpeed='0' else clk; --Older MMC and early SD cards need a 400khz Initialisation clock. Haven't come across one yet that wont init at 1mhz
SD_Clk<=SPIclock when State="10" and (SpiClkCount > 2) else '0'; --Enable the SPI clock when we're in state 3
SD_CS <=  not SPIsdCS;

process (clk)--Clock prescaler for System Clock
begin
if rising_edge(clk) then
		ClkPrescale<=ClkPrescale+1;
end if;
end process;

--The basics of this SPI code is: A state machine with 3 states. State 1 is idle, when it gets a trigger it sets state 2. State 2 buffers the data to be sent,
--State 3 shifts out 8 bits, then it returns to idle state. Also while in state 3, we read back the spi data into anothe register.
process (SPIclock,SPIClkCount,SPIoutBuffer,state)
begin
	if (falling_edge(SPIclock)) then
		if State = "00" then
			if Start='1' then
				SPIclkCount<="0000";
				State<="01";
				end if;
			end if;
		if State="01" then 
			SPIbuffer <= SPIoutBuffer;
			spiclkcount<=spiclkcount+1;
			if spiclkcount="0001" then
				state<="10";
				end if;
			end if;
		if State= "10" then --State 1=running, 0=idle
			SPIclkCount <= SPIclkCount + 1;
			if SPIclkCount="1010" then 
				State<="00";
				end if;
			SD_O <= SPIBuffer(7);
			SPIBuffer(7 downto 1) <= SPIBuffer(6 downto 0);
			end if;
		end if;
end process;
 
 
process (SPIclock,SPIClkCount,SPIinBuffer,state)
begin
	if (rising_edge(SPIclock)) then
		if State= "10" then --State 1=running, 0=idle
			SPIinBuffer (7 downto 1) <= SPIinBuffer (6 downto 0);
			SPIinBuffer(0)<=SD_I;
		end if;
	end if;
end process;
 
   
 
 
 
 
end architecture Behavioral;