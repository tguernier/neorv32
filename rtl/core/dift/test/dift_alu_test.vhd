library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity dift_alu_test is

end entity dift_alu_test;

architecture dift_alu_testbench of dift_alu_test is
  -- globals --
  signal t_clk_i      : std_ulogic := '1';
  signal t_rstn_i     : std_ulogic := '0';
  signal t_ctrl_i     : std_ulogic_vector(1 downto 0);
  -- data input --
  signal t_rs1_tag_i  : std_ulogic_vector(3 downto 0);
  signal t_rs2_tag_i  : std_ulogic_vector(3 downto 0);
  -- data output --
  signal t_res_o      : std_ulogic_vector(3 downto 0);
 
begin
  t_clk_i <= not t_clk_i after 10 ns; -- clock gen
  
  dut: entity neorv32.dift_alu
  port map (
    clk_i       => t_clk_i,
    rstn_i      => t_rstn_i,
    dift_ctrl_i => t_ctrl_i,
    rs1_tag_i   => t_rs1_tag_i,
    rs2_tag_i   => t_rs2_tag_i,
    res_o       => t_res_o
  );

  process
  begin
    t_ctrl_i    <= "00", "01" after 100 ns, "10" after 200 ns, "11" after 300 ns;
    t_rs1_tag_i <= "1100";
    t_rs2_tag_i <= "1010";
    
    wait for 500 ns;
  end process;

end architecture dift_alu_testbench;

