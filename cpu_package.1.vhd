--------------------------------------------------------------------------------
-- RISC processor general definitions
-- THIEBOLT Francois le 08/03/04
--------------------------------------------------------------------------------

-- library definitions
library IEEE;

-- library uses
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- -----------------------------------------------------------------------------
-- the package contains types, constants, and function prototypes
-- -----------------------------------------------------------------------------
package cpu_package is

-- ===============================================================
-- TYPES/CONSTRAINT DEFINITIONS
-- ===============================================================

------------------------------------------------------------------
-- HARDWARE definitions
------------------------------------------------------------------
-- define CPU core physical sizes
	constant CPU_DATA_WIDTH		: positive := 32; -- data bus width
	constant CPU_ADR_WIDTH		: positive := 32; -- address bus width, byte format

-- define MISC CPU CORE specs
	constant CPU_WR_FRONT		: std_logic := '1'; -- pipes write active front

-- define REGISTERS physical sizes
	constant REG_WIDTH		: positive := 5; -- registers address bus with
	constant REG_FRONT		: std_logic := CPU_WR_FRONT;

-- define CACHE physical sizes
	constant L1_SIZE		 	: positive := 16; -- taille du cache L1 en nombre de mots
	constant L1_FRONT			: std_logic := CPU_WR_FRONT;

------------------------------------------------------------------
-- SOFTWARE definitions
------------------------------------------------------------------
-- define the basic ALU operations
	-- Le fait qu'une operation soit signee ou non sera indique a l'ALU par un signal
	--		supplementaire, ceci dit cela n'affecte que les bits d'etat.
	type ALU_OPS is (ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_NOR, ALU_XOR, ALU_SLT, ALU_LSL, ALU_LSR);

-- define the size of datas during memory access
	type MEM_DS is (MEM_8,MEM_16,MEM_32,MEM_64);

-- ===============================================================
-- DEFINITION DE FONCTIONS/PROCEDURES
-- ===============================================================

-- Si on ne specifie rien devant les parametres...il considere que c'est une variable
-- exemple : procedure adder_cla (A,B: in std_logic_vector;...)
-- ici A et B sont consideres comme etant des variables...
-- Sinon il faut : procedure adder_cla (signal A,B: in std_logic_vector;...)

	-- fonction log2
	--		calcule le logarithme base2 d'un entier naturel, ou plus exactement
	--		renvoie le nombre de bits necessaire pour coder un entier naturel I
	function log2 (I: in natural) return natural;

	-- fonction "+" --> procedure adder_cla
	function "+" (A,B: in std_logic_vector) return std_logic_vector;

	-- procedure adder_cla
	procedure adder_cla (A,B: in std_logic_vector; C_IN : in std_logic;
							S : out std_logic_vector; C_OUT : out std_logic;
							V : out std_logic);

	-- On notera l'utilisation d'un signal comme parametres formels de type OUT
	-- procedure alu
--	procedure alu (A,B: in std_logic_vector; signal S: out std_logic_vector;
--						signal N,V,Z,C: out std_logic; SIGNED_OP: in std_logic;
--						CTRL_ALU: in ALU_OPS);

end cpu_package;

-- -----------------------------------------------------------------------------
-- the package contains types, constants, and function prototypes
-- -----------------------------------------------------------------------------
package body cpu_package is

-- ===============================================================
-- DEFINITION DE FONCTIONS/PROCEDURES
-- ===============================================================

-- fonction log2
function log2 (I: in natural) return natural is
	variable ip : natural := 1; -- valeur temporaire
	variable iv : natural := 0; -- nb de bits
begin
	while ip < i loop
		ip := ip + ip; -- ou ip := ip * 2
		iv := iv + 1;
	end loop;
	-- renvoie le nombre de bits
	return iv;
end log2;

-- fonction "+" --> procedure adder_cla
function "+" (A,B: in std_logic_vector) return std_logic_vector is
	variable C_out, V : std_logic;
	variable res : std_logic_vector(A'range);
begin
	adder_cla(A, B, '0', res, C_OUT, V);
	return res;
end "+";

-- Le drapeau overflow V ne sert que lors d'operations signees !!!
-- Overflow V=1 si operation signee et :
--		addition de deux grands nombres positifs dont le resultat < 0
--		addition de deux grands nombres negatifs dont le resultat >= 0
--		soustraction d'un grand nombre positif et d'un grand nombre negatif dont le resultat < 0
--		soustraction d'un grand nombre negatif et d'un grand nombre positif dont le resultat >= 0
--	Reviens a faire V = C_OUT xor <carry entrante du dernier bit>
-- procedure adder_cla
procedure adder_cla (A,B: in std_logic_vector;C_IN : in std_logic;
							S : out std_logic_vector;C_OUT : out std_logic;
							V : out std_logic) is
	variable G_CLA,P_CLA	: std_logic_vector(A'length-1 downto 0);
	variable C_CLA		: std_logic_vector(A'length downto 0);
begin
	-- calcul de P et G
	G_CLA := A and B;
	P_CLA := A or B;
	C_CLA(0) := C_IN;
	for I in A'low to A'high loop
		C_CLA(i+1) := G_CLA(i) or (P_CLA(i) and C_CLA(i));
	end loop;
		S := (A xor B) xor C_CLA(A'range);
		C_OUT := C_CLA(C_CLA'high);
		V := C_CLA(C_CLA'high) xor C_CLA(C_CLA'high-1);
end adder_cla;

-- procedure alu
--procedure alu (A,B: in std_logic_vector;signal S: out std_logic_vector;
--					signal N,V,Z,C: out std_logic;SIGNED_OP: in std_logic;
--					CTRL_ALU: in ALU_OPS) is
--begin
--end alu;

end cpu_package;
