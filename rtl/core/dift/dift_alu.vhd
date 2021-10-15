library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity dift_alu is
  port (
    -- globals --
    clk_i       : in std_ulogic;
    rstn_i      : in std_ulogic;
    dift_ctrl_i : in std_ulogic_vector(1 downto 0); -- test control input (TODO: add to control bus)
    -- ctrl_i      : in std_ulogic_vector(ctrl_width-1 downto 0); -- cpu control bus
    -- data input --
    rs1_tag_i   : in std_ulogic_vector(3 downto 0); -- rf source 1 dift tag
    rs2_tag_i   : in std_ulogic_vector(3 downto 0); -- rf source 2 dift tag
    -- data output  --
    res_o       : out std_ulogic_vector(3 downto 0) -- ALU result
  );
end entity dift_alu;

architecture dift_alu_rtl of dift_alu is
  -- result --
  signal alu_res  : std_ulogic_vector(3 downto 0);

begin

  -- Binary ALU --------------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- Operations --------------------------------------------------------------------------------
  -- 0b00: alu_res <= 0b0000 -------------------------------------------------------------------
  -- 0b01: alu_res <= rs1_tag_i AND rs2_tag_i --------------------------------------------------
  -- 0b10: alu_res <= rs1_tag_i OR  rs2_tag_i --------------------------------------------------
  -- 0b11: alu_res <= rs1_tag_i ----------------------------------------------------------------
  ---------------------------------------------------------------------------------------------
  dift_alu_core: process(dift_ctrl_i, rs1_tag_i, rs2_tag_i)
  begin
    case dift_ctrl_i is
      when "00" =>
        alu_res <= "0000";
      when "01" =>
        alu_res <= rs1_tag_i and rs2_tag_i;
      when "10" =>
        alu_res <= rs1_tag_i or rs2_tag_i;
      when "11" =>
        alu_res <= rs1_tag_i;
      when others =>
        alu_res <= "0000";
    end case;
  end process dift_alu_core;

  res_o <= alu_res;
   
end dift_alu_rtl;

