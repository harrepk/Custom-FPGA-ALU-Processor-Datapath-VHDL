LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dec4to16 IS
    PORT ( S  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);    -- current_state from FSM
           En : IN  STD_LOGIC;                        -- enable (tie to '1')
           OP : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );  -- one-hot microcode
END dec4to16;

ARCHITECTURE Behavior OF dec4to16 IS
    SIGNAL d : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    WITH S SELECT
        d <= "0000000000000001" WHEN "0000",
             "0000000000000010" WHEN "0001",
             "0000000000000100" WHEN "0010",
             "0000000000001000" WHEN "0011",
             "0000000000010000" WHEN "0100",
             "0000000000100000" WHEN "0101",
             "0000000001000000" WHEN "0110",
             "0000000010000000" WHEN "0111",
             "0000000100000000" WHEN "1000",
             "0000000000000000" WHEN OTHERS;

    OP <= d WHEN En = '1' ELSE (OTHERS => '0');
END Behavior;
