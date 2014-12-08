library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
  
  port (
    MCLK1 : in  std_logic;
    RS_TX : out std_logic);

end top;

architecture example of top is
  component u232c
    generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
    port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           go   : in  STD_LOGIC;
           busy : out STD_LOGIC;
           tx   : out STD_LOGIC);
  end component;

  component fadd
    port (
      a : in  std_logic_vector(31 downto 0);
      b : in  std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
  end component;
  
  type rom_t is array(0 to 7) of std_logic_vector(31 downto 0);
  --constant strrom: rom_t := (x"30", x"35", x"31", x"34", x"31", x"30", x"31", x"31");
  constant as: rom_t := ("10000000011010011001011110110101",  --7m
                         "00000000000110100011110110011000",  --8
                         "01111110100001011111001111010100",  --10m
                         "00110011100000001000001001000000",  --t1m
                         "01111111101110000101101011100010",  --5
                         "01111111100000000000000000000000",  --6
                         "00111111100000000000000000000000",  --9m
                         "00111111100000000000000000000000");  --11m
  constant bs: rom_t := ("10000000001011110001011011010101",
                         "00001000001101110111001001110010",
                         "01111111011000111010000111010100",
                         "01110011111001010100011101110111",
                         "01111111100110111001000110100010",
                         "01111111110000000000000000000000",
                         "00111111100000000000000000000000",
                         "10110011000000000000000000000001");
  constant os: rom_t := ("10000000001011110001011011010101",
                         "00001000001101110111001001110010",
                         "01111111100000000000000000000000",
                         "01110011111001010100011101110111",
                         "01111111101110000101101011100010",
                         "01111111110000000000000000000000",
                         "01000000000000000000000000000000",
                         "00111111011111111111111111111111");
  signal a1,b1 : std_logic_vector(31 downto 0);
  signal answer : std_logic_vector(31 downto 0);
  
  signal rom_addr: std_logic_vector(2 downto 0) := (others=>'0');

  signal clk,iclk: STD_LOGIC;
  signal sum : std_logic_vector(7 downto 0) := x"30";
  signal uart_go: std_logic;
  signal uart_busy: std_logic := '0';
  signal rom_o: std_logic_vector(7 downto 0);
begin  -- example

  ib: IBUFG port map (
    i=>MCLK1,
    o=>iclk);

  bg: BUFG port map (
    i=>iclk,
    o=>clk);

  rfadd: fadd
    port map(a1,b1,answer);
  a1 <= as(conv_integer(rom_addr));
  b1 <= bs(conv_integer(rom_addr));
  rs232c: u232c
    generic map (wtime=>x"1ADB")
    port map (
      clk=>clk,
      data=>rom_o,
      go=>uart_go,
      busy=>uart_busy,
      tx=>rs_tx);

  rom_inf: process(clk)
  begin
    if rising_edge(clk) then
      rom_o<=sum;
    end if;
  end process;
  send_msg: process(clk)
  begin
    if rising_edge(clk) then
      if uart_busy='0' and uart_go='0' then
        uart_go<='1';
        rom_addr<=rom_addr+1;
        if answer /= os(conv_integer(rom_addr)) then
          sum <= x"30" + rom_addr;
        else
          sum <= x"38";
        end if;
      else
        uart_go<='0';
      end if;
    end if;
  end process;  
  
end example;
