DROP TABLE rman_stack;
DROP TABLE rman_rpipe;
DROP TABLE rman_ruleblocks_dep;
DROP TABLE rman_ruleblocks;

CREATE TABLE rman_stack
(
    id INT NOT NULL,
    where_clause VARCHAR2(4000),
    from_clause VARCHAR2(4000),
    select_clause VARCHAR2(4000),
    groupby_clause VARCHAR2(100),
    varid VARCHAR2(100),
    is_sub NUMBER(1,0),
    agg_func VARCHAR2(100),
    func_param  VARCHAR2(100)
);
/

CREATE TABLE rman_rpipe
(
    ruleid varchar2(100),
    rulebody varchar2(4000),
    blockid varchar2(100),
    CONSTRAINT pk_rpipe PRIMARY KEY(ruleid)
);
/




CREATE TABLE rman_ruleblocks
(
    blockid             VARCHAR2(100),
    picoruleblock       CLOB,
    sqlblock            CLOB,
    target_table        VARCHAR2(100),
    environment         VARCHAR2(30),
    rule_owner          VARCHAR2(30),
    is_active           NUMBER(1,0),
    def_exit_prop       VARCHAR2(30),
    def_predicate       VARCHAR2(100),
    CONSTRAINT pk_ruleblocks PRIMARY KEY(blockid)
);
/
CREATE TABLE rman_ruleblocks_dep
(
    blockid varchar2(100),
    dep_table   VARCHAR2(30),
    dep_column  VARCHAR2(100),
    dep_att     VARCHAR2(100),
    dep_func    VARCHAR2(100),
    CONSTRAINT fk_ruleblock FOREIGN KEY(blockid) REFERENCES rman_ruleblocks(blockid)
);
/

CREATE OR REPLACE TYPE tbl_type AS TABLE OF VARCHAR2(2000);
/
CREATE OR REPLACE TYPE tbl_type2 AS TABLE OF VARCHAR2(32767);
/
