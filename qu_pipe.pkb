CREATE OR REPLACE PACKAGE BODY qu_pipe IS

   /************************************************************************
   GNU General Public License for utPLSQL
   
   Copyright (C) 2000-2004
   Steven Feuerstein and the utPLSQL Project
   (steven@stevenfeuerstein.com)
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program (see license.txt); if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   ************************************************************************
   $Log: ut_pipe.pkb,v $
   Revision 1.3  2005/01/19 16:10:59  chrisrimmer
   Removed AUTHID clauses from package bodies
   
   Revision 1.2  2004/11/23 15:02:18  chrisrimmer
   Added missing preprocessor flags
   
   Revision 1.1  2004/11/23 14:56:47  chrisrimmer
   Moved dbms_pipe code into its own package.  Also changed some preprocessor flags
   
   
   ************************************************************************/

   PROCEDURE receive_and_unpack(pipe_in IN VARCHAR2
                               ,msg_tbl_out OUT msg_tbltype
                               ,pipe_status_out IN OUT PLS_INTEGER) IS
      invalid_item_type EXCEPTION;
      null_msg_tbl msg_tbltype;
      next_item INTEGER;
      item_count INTEGER := 0;
      tmp msg_rectype;
   BEGIN
      -- pipe_status_out := dbms_pipe.receive_message(pipe_in, timeout => 0);
      EXECUTE IMMEDIATE 'begin :pipe_status_out := dbms_pipe.receive_message(:pipe_in, timeout => 0); end;'
         USING OUT pipe_status_out, pipe_in;
   
      IF pipe_status_out != 0
      THEN
         RAISE invalid_item_type;
      END IF;
   
      LOOP
         -- next_item := dbms_pipe.next_item_type;
         EXECUTE IMMEDIATE 'begin :next_item := dbms_pipe.next_item_type; end;'
            USING OUT next_item;
         EXIT WHEN next_item = 0;
         item_count := item_count + 1;
         msg_tbl_out(item_count).item_type := next_item;
      
         IF next_item = 9
         THEN
            -- dbms_pipe.unpack_message(msg_tbl_out(item_count).mvc2);
            EXECUTE IMMEDIATE 'begin dbms_pipe.unpack_message( :item ); end;'
               USING OUT tmp.mvc2;
            msg_tbl_out(item_count).mvc2 := tmp.mvc2;
         ELSIF next_item = 6
         THEN
            -- dbms_pipe.unpack_message(msg_tbl_out(item_count).mnum);
            EXECUTE IMMEDIATE 'begin dbms_pipe.unpack_message( :item ); end;'
               USING OUT tmp.mnum;
            msg_tbl_out(item_count).mnum := tmp.mnum;
         ELSIF next_item = 11
         THEN
            -- dbms_pipe.unpack_message_rowid(msg_tbl_out(item_count).mrid);
            EXECUTE IMMEDIATE 'begin dbms_pipe.unpack_message( :item ); end;'
               USING OUT tmp.mrid;
            msg_tbl_out(item_count).mrid := tmp.mrid;
         ELSIF next_item = 12
         THEN
            -- dbms_pipe.unpack_message(msg_tbl_out(item_count).mdt);
            EXECUTE IMMEDIATE 'begin dbms_pipe.unpack_message( :item ); end;'
               USING OUT tmp.mdt;
            msg_tbl_out(item_count).mdt := tmp.mdt;
         ELSIF next_item = 23
         THEN
            -- dbms_pipe.unpack_message_raw(msg_tbl_out(item_count).mraw);
            EXECUTE IMMEDIATE 'begin dbms_pipe.unpack_message( :item ); end;'
               USING OUT tmp.mraw;
            msg_tbl_out(item_count).mraw := tmp.mraw;
         ELSE
            RAISE invalid_item_type;
         END IF;
      
         --next_item := dbms_pipe.next_item_type;
         EXECUTE IMMEDIATE 'begin :next_item := dbms_pipe.next_item_type; end;'
           USING OUT next_item;
      END LOOP;
   EXCEPTION
      WHEN invalid_item_type THEN
         msg_tbl_out := null_msg_tbl;
   END receive_and_unpack;

END qu_pipe;
/
