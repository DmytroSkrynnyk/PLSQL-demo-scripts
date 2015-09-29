CREATE OR REPLACE PROCEDURE log_error(
      err_in IN PLS_INTEGER := SQLCODE ,
      msg_in IN VARCHAR2    := NULL)
IS
   pragma autonomous_transaction;
BEGIN

   INSERT
      INTO log_table
         (
            logcode,
            logmsg,
            callstack,
            errorstack,
            backtrace,
            created_by,
            created_at
         )
         VALUES
         (
            err_in,
            msg_in,
            DBMS_UTILITY.format_call_stack,
            DBMS_UTILITY.format_error_stack,
            DBMS_UTILITY.format_error_backtrace,
            USER,
            SYSDATE
         );
   COMMIT;

END;
/