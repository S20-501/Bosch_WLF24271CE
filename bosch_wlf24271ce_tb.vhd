LIBRARY ieee  ;
LIBRARY work  ;
USE ieee.std_logic_1164.all  ;
USE work.sevenseg_pkg.all  ;
ENTITY bosch_wlf24271ce_tb  IS
END ;

ARCHITECTURE bosch_wlf24271ce_tb_arch OF bosch_wlf24271ce_tb IS
  SIGNAL DS_B   :  STD_LOGIC  ;
  SIGNAL DS_C   :  STD_LOGIC  ;
  SIGNAL DS_DP   :  STD_LOGIC  ;
  SIGNAL DS_D   :  STD_LOGIC  ;
  SIGNAL DS_EN1   :  STD_LOGIC  ;
  SIGNAL BP1   :  STD_LOGIC  ;
  SIGNAL DS_E   :  STD_LOGIC  ;
  SIGNAL DS_EN2   :  STD_LOGIC  ;
  SIGNAL DS_F   :  STD_LOGIC  ;
  SIGNAL DS_EN3   :  STD_LOGIC  ;
  SIGNAL DS_EN4   :  STD_LOGIC  ;
  SIGNAL DS_G   :  STD_LOGIC  ;
  SIGNAL KEY1   :  STD_LOGIC := '0'  ;
  SIGNAL CLK   :  STD_LOGIC := '0' ;
  SIGNAL KEY2   :  STD_LOGIC := '0'  ;
  SIGNAL KEY3   :  STD_LOGIC := '0'  ;
  SIGNAL KEY4   :  STD_LOGIC := '0'  ;
  SIGNAL V_R   :  std_logic_vector (4 downto 0)  ;
  SIGNAL DS_A   :  STD_LOGIC  ;
  COMPONENT Bosch_WLF24271CE
    PORT (
      DS_B  : out STD_LOGIC ;
      DS_C  : out STD_LOGIC ;
      DS_DP  : out STD_LOGIC ;
      DS_D  : out STD_LOGIC ;
      DS_EN1  : out STD_LOGIC ;
      BP1  : out STD_LOGIC ;
      DS_E  : out STD_LOGIC ;
      DS_EN2  : out STD_LOGIC ;
      DS_F  : out STD_LOGIC ;
      DS_EN3  : out STD_LOGIC ;
      DS_EN4  : out STD_LOGIC ;
      DS_G  : out STD_LOGIC ;
      KEY1  : in STD_LOGIC ;
      CLK  : in STD_LOGIC ;
      KEY2  : in STD_LOGIC ;
      KEY3  : in STD_LOGIC ;
      KEY4  : in STD_LOGIC ;
      V_R  : out std_logic_vector (4 downto 0) ;
      DS_A  : out STD_LOGIC );
  END COMPONENT ;
BEGIN
  DUT  : Bosch_WLF24271CE
    PORT MAP (
      DS_B   => DS_B  ,
      DS_C   => DS_C  ,
      DS_DP   => DS_DP  ,
      DS_D   => DS_D  ,
      DS_EN1   => DS_EN1  ,
      BP1   => BP1  ,
      DS_E   => DS_E  ,
      DS_EN2   => DS_EN2  ,
      DS_F   => DS_F  ,
      DS_EN3   => DS_EN3  ,
      DS_EN4   => DS_EN4  ,
      DS_G   => DS_G  ,
      KEY1   => KEY1  ,
      CLK   => CLK  ,
      KEY2   => KEY2  ,
      KEY3   => KEY3  ,
      KEY4   => KEY4  ,
      V_R   => V_R  ,
      DS_A   => DS_A   ) ;


    CLK <= not CLK after 1 ps;

    


END ;
