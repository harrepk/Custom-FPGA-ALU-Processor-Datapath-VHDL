LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu IS
    PORT ( Clock : IN  STD_LOGIC;
           A, B  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   -- from the two registers
           OP    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);  -- microcode from decoder
           Neg   : OUT STD_LOGIC;                       -- '1' when A-B is negative
           R1    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    -- lower 4 bits of Result
           R2    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );  -- upper 4 bits of Result
END alu;

ARCHITECTURE calculation OF alu IS
    SIGNAL Reg1, Reg2, Result : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN
    Reg1 <= A;     -- local copy of A
    Reg2 <= B;     -- local copy of B

    PROCESS ( Clock )
    BEGIN
        IF rising_edge(Clock) THEN
            Neg <= '0';                       -- default, overridden by func 7
            CASE OP IS
                -- 1: swap lower & upper nibbles of A
                WHEN "0000000000000001" =>
                    Result <= Reg1(3 DOWNTO 0) & Reg1(7 DOWNTO 4);

                -- 2: A OR B
                WHEN "0000000000000010" =>
                    Result <= Reg1 OR Reg2;

                -- 3: B - 5
                WHEN "0000000000000100" =>
                    Result <= STD_LOGIC_VECTOR( UNSIGNED(Reg2) - 5 );

                -- 4: NOT A
                WHEN "0000000000001000" =>
                    Result <= NOT Reg1;

                -- 5: reverse bit-significance order of A
                WHEN "0000000000010000" =>
                    Result <= Reg1(0) & Reg1(1) & Reg1(2) & Reg1(3) &
                              Reg1(4) & Reg1(5) & Reg1(6) & Reg1(7);

                -- 6: Max(A, B)
                WHEN "0000000000100000" =>
                    IF UNSIGNED(Reg1) >= UNSIGNED(Reg2) THEN
                        Result <= Reg1;
                    ELSE
                        Result <= Reg2;
                    END IF;

                -- 7: difference between A and B (magnitude + sign)
                WHEN "0000000001000000" =>
                    IF UNSIGNED(Reg1) >= UNSIGNED(Reg2) THEN
                        Result <= STD_LOGIC_VECTOR( UNSIGNED(Reg1) - UNSIGNED(Reg2) );
                        Neg    <= '0';
                    ELSE
                        Result <= STD_LOGIC_VECTOR( UNSIGNED(Reg2) - UNSIGNED(Reg1) );
                        Neg    <= '1';
                    END IF;

                -- 8: A XNOR B
                WHEN "0000000010000000" =>
                    Result <= NOT (Reg1 XOR Reg2);

                -- 9: rotate B left by 3 (ROL)
                WHEN "0000000100000000" =>
                    Result <= Reg2(4 DOWNTO 0) & Reg2(7 DOWNTO 5);

                WHEN OTHERS =>
                    Result <= Result;          -- hold (don't care)
            END CASE;
        END IF;
    END PROCESS;

    R1 <= Result(3 DOWNTO 0);   -- lower nibble -> HEX0
    R2 <= Result(7 DOWNTO 4);   -- upper nibble -> HEX2
END calculation;
