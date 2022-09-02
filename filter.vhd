library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
	generic (
		M : integer := 8; -- number of coefficients
		N_coeff : integer := 16; -- coefficients width
		N_out : integer := 8; -- out vector width
		N_in : integer := 8 -- input vector width
	);
	port (
		clk, reset : in std_logic;
		data_in : in std_logic_vector(N_in - 1 downto 0);
		data_out : out std_logic_vector(N_out - 1 downto 0)
	);
end filter;

architecture arch of filter is
	type array_coeff is array (0 to M - 1) of signed(N_coeff - 1 downto 0);
	type array_reg is array (0 to M - 1) of signed(N_in + N_coeff - 1 downto 0);
	-- coefficients from matlab
	signal coeff : array_coeff := ("0000111110100111", "0010010111011101", "0100000000000110", "0101000110100000", "0101000110100000", "0100000000000110", "0010010111011101", "0000111110100111");
	signal a_reg, b_reg : array_reg;

begin

	process (clk, reset)
	begin
		if (reset = '1') then
			a_reg <= (others => (others => '0'));
			b_reg <= (others => (others => '0'));

		elsif (clk = '1' and clk'event) then
			for i in 0 to M - 1 loop
				if (i < M - 1) then
					a_reg(i) <= coeff(i) * signed(data_in);
					b_reg(i) <= a_reg(i) + b_reg(i + 1);
				elsif (i = M - 1) then
					a_reg(i) <= coeff(i) * signed(data_in);
					b_reg(i) <= a_reg(i);
				end if;
			end loop;
		end if;
	end process;

	data_out <= std_logic_vector(b_reg(0)(N_coeff + N_in - 1 downto N_coeff + N_in - N_out));

end arch;