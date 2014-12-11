-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_textio.all;

use std.textio.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS

  -- Component Declaration
  COMPONENT fadd
    PORT(clk : in std_logic;
         a : IN std_logic_vector(31 downto 0);
         b : IN std_logic_vector(31 downto 0);
         o : OUT std_logic_vector(31 downto 0));
  END COMPONENT;

  SIGNAL i1 :  std_logic_vector(31 downto 0);
  SIGNAL i2 :  std_logic_vector(31 downto 0);
  SIGNAL o1 :  std_logic_vector(31 downto 0);
  signal clk : std_logic;

BEGIN

  -- Component Instantiation
  uut: fadd PORT MAP(
    clk => clk,
    a => i1,
    b => i2,
    o => o1);

  --  Test Bench Statements
  tb : PROCESS
    file infile : text is in "/home/morihiro/2014-summer/hardware/kadai7/txt/random_for_read.txt";
    file outfile : text is out "/home/morihiro/2014-summer/hardware/kadai7/sim.txt";
    variable my_line, out_line : LINE;
    variable a, b, c : std_logic_vector(31 downto 0);
  BEGIN

    wait for 100 ns; -- wait until global set/reset completes

    -- Add user defined stimulus here

    while not endfile(infile) loop
      readline(infile, my_line);
      read(my_line, a);
      readline(infile, my_line);
      read(my_line, b);

      i1 <= a;
      i2 <= b;

      wait for 28 ns;

      c := o1;

      write(out_line, c);
      writeline(outfile, out_line);
    end loop;

  END PROCESS;
  clkgen : PROCESS
    begin
      clk <= '0';
      wait for 7 ns;
      clk <= '1';
      wait for 7 ns;
    end PROCESS;
  --  End Test Bench

end behavior;
