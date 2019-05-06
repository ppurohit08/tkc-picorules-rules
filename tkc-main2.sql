CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

DECLARE

    
    strsql      CLOB;
    
    blockid     varchar2(100);
    
    rb          RMAN_RULEBLOCKS%ROWTYPE;

BEGIN
   
    
    blockid:='ckd-1-2';
    
    rman_pckg.parse_ruleblocks(blockid);
    
    rman_pckg.parse_rpipe(strsql);
    
    UPDATE rman_ruleblocks SET sqlblock=strsql WHERE blockid=blockid;
    
    SELECT * INTO rb FROM rman_ruleblocks WHERE blockid=blockid AND ROWNUM<2;
   
    DBMS_OUTPUT.PUT_LINE('RMAN execution -->' || chr(10));
    DBMS_OUTPUT.PUT_LINE('Rule block id : ' || rb.blockid || chr(10));
    DBMS_OUTPUT.PUT_LINE('Target tbl    : ' || rb.target_table || chr(10));
    DBMS_OUTPUT.PUT_LINE('Environment   : ' || rb.environment || chr(10));
    
    rman_pckg.exec_dsql(rb.sqlblock,rb.target_table);
    
  
    
    
    
END;



