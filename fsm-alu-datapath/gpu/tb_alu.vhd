LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_alu IS END tb_alu;

ARCHITECTURE sim OF tb_alu IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL A, B : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL OP : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Neg : STD_LOGIC;
    SIGNAL R1, R2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    TYPE arr IS ARRAY(1 TO 9) OF INTEGER;
    -- expected for A=0xA3,B=0x95 (verified Python model)
    CONSTANT exp_res : arr := (16#3A#,16#B7#,16#90#,16#5C#,16#C5#,16#A3#,16#0E#,16#C9#,16#AC#);
    CONSTANT exp_neg : arr := (0,0,0,0,0,0,0,0,0);
BEGIN
    DUT : ENTITY work.alu PORT MAP ( Clock=>clk, A=>A, B=>B, OP=>OP, Neg=>Neg, R1=>R1, R2=>R2 );
    PROCESS
        VARIABLE res : INTEGER;
    BEGIN
        A <= x"A3"; B <= x"95";
        WAIT FOR 2 ns;                      -- let Reg1/Reg2 settle
        FOR f IN 1 TO 9 LOOP
            OP <= STD_LOGIC_VECTOR(to_unsigned(2**(f-1),16));
            WAIT FOR 3 ns; clk <= '1'; WAIT FOR 5 ns;   -- rising edge registers Result
            res := to_integer(unsigned(R2 & R1));
            ASSERT res = exp_res(f)
                REPORT "FUNC "&INTEGER'IMAGE(f)&" WRONG got "&INTEGER'IMAGE(res)&
                       " exp "&INTEGER'IMAGE(exp_res(f)) SEVERITY FAILURE;
            ASSERT (Neg='1')=(exp_neg(f)=1)
                REPORT "FUNC "&INTEGER'IMAGE(f)&" NEG WRONG" SEVERITY FAILURE;
            REPORT "func "&INTEGER'IMAGE(f)&" Result=0x"&INTEGER'IMAGE(res)&
                   " Neg="&STD_LOGIC'IMAGE(Neg)&" OK";
            clk <= '0'; WAIT FOR 5 ns;
        END LOOP;
        -- func7 negative case: A=0x10,B=0x95 -> |diff|=0x85, Neg=1
        A <= x"10"; B <= x"95"; OP <= STD_LOGIC_VECTOR(to_unsigned(2**6,16));
        WAIT FOR 3 ns; clk<='1'; WAIT FOR 5 ns;
        ASSERT to_integer(unsigned(R2&R1))=16#85# AND Neg='1'
            REPORT "FUNC7 neg-case WRONG" SEVERITY FAILURE;
        REPORT "func 7 neg-case Result=0x85 Neg=1 OK";
        clk<='0'; WAIT FOR 2 ns;
        REPORT "ALL PROBLEM 2(b) ALU CHECKS PASSED" SEVERITY NOTE;
        WAIT;
    END PROCESS;
END sim;
