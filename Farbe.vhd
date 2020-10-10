LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_textio.ALL;
USE std.env.finish;
USE std.textio.ALL;

ENTITY Farbe IS
END ENTITY;

ARCHITECTURE reading OF Farbe IS

    TYPE charf IS FILE OF CHARACTER;
    TYPE header4_8 IS ARRAY (0 TO 85) OF CHARACTER;             --Gültig für 4bpp und 8bpp

BEGIN
    PROCESS
        VARIABLE char1 : CHARACTER;
        VARIABLE char2 : CHARACTER;
        VARIABLE char3 : CHARACTER;
        VARIABLE char4 : CHARACTER;
        VARIABLE char6 : CHARACTER;
        VARIABLE bpp   : INTEGER;              -- Bits Per Pixel

        FILE INfile : charf OPEN read_mode IS "Ghassen.bmp";

        FILE OUTfile : charf OPEN write_mode IS "Ghassenout.bmp";

        VARIABLE header : header4_8;

    BEGIN

        FOR i IN 0 TO 85 LOOP
            read(INfile, header(i)); -- Von 0 bis 85 bleibt die Header konstant : nichts ist zu ändern
        END LOOP;


        FOR i IN 0 TO 85 LOOP
            write(OUTfile, header(i)); -- Von 0 bis 85 bleibt die Header konstant : nichts ist zu ändern
        END LOOP;


        bpp := CHARACTER'pos(header(28)); --header(28) ist , wo die Anzahl der bpp steht (entweder 4 , 8 oder 24)

        IF (bpp = 4 OR bpp = 8) THEN
            char6 := 'ÿ';                  --FF im Hexadecimal 

            WHILE NOT endfile(INfile) LOOP    -- BB GG RR(00)   
                                                -- FF 00 00(00)    Blaue               
                                                -- 00 00 FF(00)    Rot
                read(INfile, char1);
                read(INfile, char2);                    -- ..ÿ. ist rot in 4bpp                                         p 
                read(INfile, char3);                    -- ý... ist blaue in 4 bp
                read(INfile, char4); 
             

                IF (char1 = NUL AND char2 = NUL AND char3 = char6 AND char4 = NUL) -- if (color = "..ÿ."   ___ red color)
                    THEN
                    write(OUTfile, char6);    -- ÿ
                    write(OUTfile, char1);    -- .
                    write(OUTfile, char2);    -- .
                    write(OUTfile, char4);    -- .
                                                                                  -- => write (color = "ÿ..." ___blue color)
                ELSE
                    write(OUTfile, char1);     
                    write(OUTfile, char2);    
                    write(OUTfile, char3);    
                    write(OUTfile, char4);    

                END IF;

            END LOOP;
        ELSE
            REPORT "Datei nicht 4 bpp oder 8 bpp"
                SEVERITY failure; --Abstuerz wie return 0; or exit(0) in C + // Return False
        END IF;

        file_close(INfile);
        file_close(OUTfile);

        finish; -- Mit finish weisst man wo der Programm stoppt während der Siumlation
    END PROCESS;

END ARCHITECTURE;
