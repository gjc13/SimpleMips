library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Peripherals is
    component MemDecoder
    port(   addr: in std_logic_vector(31 downto 0);
            r: in std_logic;
            w: in std_logic; data_in: in std_logic_vector(31 downto 0);
            data_out: out std_logic_vector(31 downto 0);
            sram_data:inout std_logic_vector(31 downto 0);
            sram_addr:out std_logic_vector(19 downto 0);
            ce:out std_logic;
            oe:out std_logic;
            we:out std_logic;
            serial_data_out:out std_logic_vector(31 downto 0);
            serial_data_in:in std_logic_vector(31 downto 0);
            serial_r:out std_logic;
            serial_w:out std_logic;
            serial_addr:out std_logic_vector(31 downto 0);
            flash_data_out : out std_logic_vector(31 downto 0);
            flash_data_in : in std_logic_vector(31 downto 0);
            flash_r : out std_logic;
            flash_w : out std_logic;
            flash_addr : out std_logic_vector(31 downto 0);
            cpu_clk: in std_logic;
            clk: in std_logic;
            reset : in std_logic
        );
    end component;

    component Serial 
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
            clk : in  STD_LOGIC;
            reset : in  STD_LOGIC; 
            en_r : in STD_LOGIC;
            en_w : in STD_LOGIC;
            RX : in  STD_LOGIC;
            TX : out  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR(31 downto 0);
            data_out : out  STD_LOGIC_VECTOR(31 downto 0);
            intr : out  STD_LOGIC
        );
    end component;

    component FlashCtrl
    Port ( ctrl_addr : in  STD_LOGIC_VECTOR (31 downto 0);
           data_in : in STD_LOGIC_VECTOR(31 downto 0);
           data_out : out  STD_LOGIC_VECTOR (31 downto 0);
           intr : out  STD_LOGIC;
           r : in STD_LOGIC;
           w : in STD_LOGIC;
           next_pend : in  STD_LOGIC;
           need_mem : out  STD_LOGIC;
           flash_ce : out  STD_LOGIC;
           flash_byte_mode : out  STD_LOGIC;
           flash_oe : out  STD_LOGIC;
           flash_we : out  STD_LOGIC;
           flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
           flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
           flash_vpen : out  STD_LOGIC;
           flash_rp : out  STD_LOGIC;
           mem_addr : out  STD_LOGIC_VECTOR (31 downto 0);
           mem_data_out : out  STD_LOGIC_VECTOR (31 downto 0);
           mem_data_in : in STD_LOGIC_VECTOR(31 downto 0);
           mem_r : out  STD_LOGIC;
           mem_w : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           cpu_clk : in STD_LOGIC;
           reset : in  STD_LOGIC);
    end component;

end Peripherals;

package body Peripherals is 
end Peripherals;

