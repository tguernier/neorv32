library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity dift_tag_check_test is

end entity dift_tag_check_test;

architecture dift_tag_check_testbench of dift_tag_check_test is
  -- globals --
  signal t_clk_i      : std_ulogic := '1';
  signal t_rstn_i     : std_ulogic := '0';
  signal t_ctrl_i     : std_ulogic_vector(3 downto 0);
  -- data input --
  signal t_rs1_tag_i  : std_ulogic_vector(3 downto 0);
  signal t_rs2_tag_i  : std_ulogic_vector(3 downto 0);
  signal t_alu_tag_i  : std_ulogic_vector(3 downto 0);
  signal t_pc_tag_i   : std_ulogic;
  -- data output --
  signal t_tag_except_o : std_ulogic;
 
begin
  t_clk_i <= not t_clk_i after 10 ns; -- clock gen
  
  dut: entity neorv32.dift_tag_check
  port map (
    clk_i         => t_clk_i,
    rstn_i        => t_rstn_i,
    dift_ctrl_i   => t_ctrl_i,
    rs1_tag_i     => t_rs1_tag_i,
    rs2_tag_i     => t_rs2_tag_i,
    alu_tag_i     => t_alu_tag_i,
    pc_tag_i      => t_pc_tag_i,
    tag_except_o  => t_tag_except_o
  );

  process
  begin
    t_ctrl_i    <= "0000", "0001" after 100 ns, "0010" after 200 ns, "0100" after 300 ns,
                   "1000" after 400 ns, "1001" after 500 ns, "0101" after 600 ns,
                   "0111" after 700 ns, "1111" after 800 ns;
    t_rs1_tag_i <= "0000", "0001" after 700 ns;
    t_rs2_tag_i <= "1111", "0000" after 300 ns;
    t_alu_tag_i <= "0000", "0110" after 300 ns, "0000" after 700 ns;
    t_pc_tag_i  <= '0', '1' after 500 ns, '0' after 600 ns;
    
    wait for 1000 ns;
  end process;

end architecture dift_tag_check_testbench;

