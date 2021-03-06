--
-- Table_size.sql
-- This code will compute the table size for an unpopulated table.
-- Note that it takes two inputs, table name and estimated number of rows
-- Copyright Precision Computer Systems, Inc. @1998,1999
--
CREATE OR REPLACE PROCEDURE ONE_TABLE_SIZE (TAB_NAME VARCHAR2, NUM_ROWS INTEGER) IS
 
	X INTEGER 	 := 0;
	Y INTEGER 	 := 0;
	Z INTEGER 	 := 0;
	COLSIZE INTEGER  := 0;
	OVER250 INTEGER  := 0;
	UNDER250 INTEGER := 0;
	TSIZE INTEGER 	 := 0;
	NUM_BLOCKS INTEGER  := 0;
	BLOCK_SIZE  INTEGER := 8192;
	PCT_FREE FLOAT 	 := 0.10;

	CURSOR C1 IS SELECT DATA_TYPE, DATA_LENGTH FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = TAB_NAME;

BEGIN
	
	FOR TAB_REC IN C1 LOOP
				
		IF TAB_REC.DATA_TYPE = 'NUMBER' THEN
			COLSIZE := COLSIZE + 21;
			UNDER250 := UNDER250 + 1;
		ELSIF TAB_REC.DATA_TYPE = 'DATE' THEN
			COLSIZE := COLSIZE + 7;
			UNDER250 := UNDER250 + 1;
		ELSE
		        COLSIZE := COLSIZE + TAB_REC.DATA_LENGTH;
			IF TAB_REC.DATA_LENGTH >= 250 THEN
				OVER250 := OVER250 + 1;
			ELSE
				UNDER250 := UNDER250 + 1;
			END IF;
		END IF;
				
	END LOOP;

	DBMS_OUTPUT.PUT_LINE('-------------------------------------');
	DBMS_OUTPUT.PUT_LINE('------ TABLE SIZE CALCULATIONS ------');
	DBMS_OUTPUT.PUT_LINE('-------------------------------------');
	DBMS_OUTPUT.PUT_LINE('TABLE NAME ......... = '||TAB_NAME);
	DBMS_OUTPUT.PUT_LINE('BLOCK SIZE ......... = '||TO_CHAR(BLOCK_SIZE));
	DBMS_OUTPUT.PUT_LINE('FREE SPACE PERCENT . = '||TO_CHAR(PCT_FREE));
	DBMS_OUTPUT.PUT_LINE('TOTAL OF COLUMNS ... = '||TO_CHAR(COLSIZE));
	DBMS_OUTPUT.PUT_LINE('COLUMNS UNDER 250 .. = '||TO_CHAR(UNDER250));
	DBMS_OUTPUT.PUT_LINE('COLUMNS OVER 250 ... = '||TO_CHAR(OVER250));

	Z := ((3 + COLSIZE) + UNDER250 + (3 * OVER250));
	DBMS_OUTPUT.PUT_LINE('CALCULATED ROW LENGTH (Z) = '||TO_CHAR(Z));
	
	IF Z < BLOCK_SIZE THEN
		X := FLOOR((BLOCK_SIZE / Z));
	ELSE
		X := CEIL((Z / BLOCK_SIZE));
	END IF;

	DBMS_OUTPUT.PUT_LINE('X = '||TO_CHAR(X));

	Y := BLOCK_SIZE - (PCT_FREE * (BLOCK_SIZE - (52 + (4*X))));

	DBMS_OUTPUT.PUT_LINE('BYTES AVAILABLE IN EACH BLOCK FOR ROW DATA (Y) = '||TO_CHAR(Y));

	IF Z < BLOCK_SIZE THEN
		WHILE Y < (X * Z) LOOP
			X := X - 1;
		END LOOP;
	END IF;
	
	IF Z < BLOCK_SIZE THEN
		NUM_BLOCKS := CEIL(NUM_ROWS / X);
	ELSE
		NUM_BLOCKS := NUM_ROWS * X;
	END IF;

	IF NUM_BLOCKS = 0 THEN
		NUM_BLOCKS := 1;
	END IF;

	TSIZE := ((BLOCK_SIZE * NUM_BLOCKS) / 1024);

	IF Z < BLOCK_SIZE THEN
		DBMS_OUTPUT.PUT_LINE('NUMBER OF ROWS CONTAINED IN A BLOCK (X)  = '||TO_CHAR(X));
	ELSE
		DBMS_OUTPUT.PUT_LINE('NUMBER OF BLOCKS NEEDED FOR EACH ROW (X) = '||TO_CHAR(X));
	END IF;
		
	DBMS_OUTPUT.PUT_LINE('NUMBER OF '||TO_CHAR(BLOCK_SIZE)||' BLOCKS REQUIRED = '||TO_CHAR(NUM_BLOCKS));
	DBMS_OUTPUT.PUT_LINE('SIZE OF TABLE FOR '||TO_CHAR(NUM_ROWS)||' ROWS = '||TO_CHAR(TSIZE)||'KB');
	
EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('ERROR MESSAGE FOLLOWS '||SQLERRM);
END;
/
SHOW ERRORS

		
