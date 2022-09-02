library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity filter_tb is
	generic (
		N_in : integer := 8; -- input vector width
		N_out : integer := 8; -- out vector width
		N_coeff : integer := 16; -- coefficients width
		M : integer := 8 -- number of coefficients
	);
end filter_tb;

architecture arch of filter_tb is
	file input_buf : text;
	file output_buf : text;

	signal clk, reset : std_logic;
	signal data_in : std_logic_vector(N_in - 1 downto 0);
	signal data_out : std_logic_vector(N_out - 1 downto 0);

	constant period : time := 10 ns;

	component filter is
		generic (
			M : integer := 11;
			N_coeff : integer := 8;
			N_out : integer := 8;
			N_in : integer := 8
		);
		port (
			clk, reset : in std_logic;
			data_in : in std_logic_vector(N_in - 1 downto 0);
			data_out : out std_logic_vector(N_out - 1 downto 0)
		);
	end component;
begin

	process
	begin
		clk <= '1';
		wait for period/2;
		clk <= '0';
		wait for period/2;
	end process;

	process (reset)
	begin

	end process;
	process (clk, reset)
		variable read_line, write_line : line;
		variable data_in_var : std_logic_vector(N_in - 1 downto 0);
	begin
		if (reset = '1' and reset'event) then
			file_open(input_buf, "input.txt", read_mode);
			file_open(output_buf, "output.txt", write_mode);
		end if;
		if (reset = '0' and clk = '1' and clk'event) then
			readline(input_buf, read_line);
			read(read_line, data_in_var);
			data_in <= data_in_var;
			write(write_line, data_out);
			writeline(output_buf, write_line);
		end if;
	end process;

	uut0 : filter generic map(M => M, N_coeff => N_coeff, N_out => N_out, N_in => N_in)
	port map(
		clk => clk, reset => reset,
		data_in => data_in,
		data_out => data_out
	);

	reset <= '1', '0' after 10 ns;

end arch;