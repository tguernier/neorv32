library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity dift_tag_check is
  port (
    -- globals --
    clk_i         : in std_ulogic;
    rstn_i        : in std_ulogic;
    ctrl_i        : in std_ulogic_vector(ctrl_width_c-1 downto 0); -- cpu control bus
    -- data input --
    rs1_tag_i     : in std_ulogic_vector(3 downto 0); -- rf source 1 dift tag
    rs2_tag_i     : in std_ulogic_vector(3 downto 0); -- rf source 2 dift tag
    alu_tag_i     : in std_ulogic_vector(3 downto 0); -- alu result dift tag
    pc_tag_i      : in std_ulogic;                    -- program counter dift tag
    -- data output --
    tag_except_o  : out std_ulogic -- exception signal
  );
end entity dift_tag_check;

architecture dift_tag_check_rtl of dift_tag_check is
  -- result --
  signal tag_except   : std_ulogic;
begin
-- dift_ctrl(3) == 1 -> check rs1_tag (bit 81)
-- dift_ctrl(2) == 1 -> check rs2_tag (bit 80)
-- dift_ctrl(1) == 1 -> check alu_tag (bit 79)
-- dift_ctrl(0) == 1 -> check pc_tag  (bit 78)

  dift_tag_check_core: process(ctrl_i, rs1_tag_i, rs2_tag_i, alu_tag_i, pc_tag_i)
    variable rs1_reduced, rs2_reduced, alu_reduced : std_ulogic; -- or-reduced DIFT tags
  begin
    rs1_reduced := or_reduce_f(rs1_tag_i);
    rs2_reduced := or_reduce_f(rs2_tag_i);
    alu_reduced := or_reduce_f(alu_tag_i);

    case ctrl_i(ctrl_dift_chk_3_c downto ctrl_dift_chk_0_c) is
      when "0000" =>
        tag_except <= '0';
      when "0001" =>
        tag_except <= rs1_reduced;
      when "0010" =>
        tag_except <= rs2_reduced;
      when "0011" =>
        tag_except <= rs2_reduced or rs1_reduced;
      when "0100" =>
        tag_except <= alu_reduced;
      when "0101" =>
        tag_except <= alu_reduced or rs1_reduced;
      when "0110" =>
        tag_except <= alu_reduced or rs2_reduced;
      when "0111" =>
        tag_except <= alu_reduced or rs2_reduced or rs1_reduced;
      when "1000" =>
        tag_except <= pc_tag_i;
      when "1001" =>
        tag_except <= pc_tag_i or rs1_reduced;
      when "1010" =>
        tag_except <= pc_tag_i or rs2_reduced;
      when "1011" =>
        tag_except <= pc_tag_i or rs2_reduced or rs1_reduced;
      when "1100" =>
        tag_except <= pc_tag_i or alu_reduced;
      when "1101" =>
        tag_except <= pc_tag_i or alu_reduced or rs1_reduced;
      when "1110" =>
        tag_except <= pc_tag_i or alu_reduced or rs2_reduced;
      when "1111" =>
        tag_except <= pc_tag_i or alu_reduced or rs2_reduced or rs1_reduced;
      when others =>
        tag_except <= '0';
    end case;
  end process dift_tag_check_core;

  tag_except_o <= tag_except;

end dift_tag_check_rtl;

