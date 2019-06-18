DROP TABLE rman_rpt_templates;
/
CREATE TABLE rman_rpt_templates
(
    templateid      varchar2(100) not null,
    ruleblockid         varchar2(100),
    placementid     INTEGER,
    templatehtml    clob,
    environment     varchar2(30),
    template_owner  varchar2(30),
    effective_dt    date,
    CONSTRAINT pk_rman_rpt_templates PRIMARY KEY(templateid)
    --CONSTRAINT fk_template_ruleblock FOREIGN KEY(ruleblockid) REFERENCES rman_ruleblocks(blockid)
);
/
DROP INDEX rman_rpt_templates_ruleblockid;
/
CREATE INDEX rman_rpt_templates_ruleblockid ON rman_rpt_templates(ruleblockid);
/


INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_dm_syn_1','cd_dm_2',602100,'dev','tkc',TO_DATE(SYSDATE),
    '
    <dm_dx_code_flag>Diagnosed</dm_dx_code_flag><dm_dx_undiagnosed>Undiagnosed</dm_dx_undiagnosed><dm_longstanding> long standing</dm_longstanding> type <dm_type></dm_type> diabetes mellitus since <dm_fd_t></dm_fd_t>.
    <dm_micvas>There are non-renal microvascular complications.</dm_micvas>The glycaemic control is <n0_st=2>optimal (6-8)</n0_st=2><n0_st=1>too tight(<6)</n0_st=1><n0_st=3>sub-optimal (8-10)</n0_st=3><n0_st=4>very sub-optimal (>10)</n0_st=4> with <n_opt_qt></n_opt_qt>% (<hba1c_n_opt></hba1c_n_opt>/<hba1c_n_tot></hba1c_n_tot>) of the readings in the optimal range.
    '
    );
    
INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_dm_rec_1','cd_dm_2',702100,'dev','tkc',TO_DATE(SYSDATE),
    '
    Recommendation [2.3] Suggest optimizing glycaemic control
    '
    );
INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_htn_syn_1','cd_htn_2',603100,'dev','tkc',TO_DATE(SYSDATE),
    '
    <htn_icpc>Diagnosed</htn_icpc> Hypertension type <htn_type></htn_type> for <htn_vintage_cat></htn_vintage_cat> decade(s),since <htn_fd_yr></htn_fd_yr>.
    <mu_1>The average systolic BP during last year was </mu_1><mu_1></mu_1><mu_1> mmHg</mu_1><mu_2> and the year before was </mu_2><mu_2></mu_2><mu_2> mmHg.</mu_2>
    <slice140_1_n></slice140_1_n> <slice140_1_n> out of  <sigma_1></sigma_1> are above 140mmHg</slice140_1_n>
    <bp_trend=1>Hypertension control appears to have improved compared to last year</bp_trend=1>
    <bp_trend=2>Hypertension control appears to have worsened compared to last year</bp_trend=2>
    BP control <bp_control=3>appears to be adequate</bp_control=3><bp_control=2>can be optimized</bp_control=2><bp_control=1>appears to sub-optimal</bp_control=1><bp_control=0>could not be determined</bp_control=0>[3.3]
    '
    );
INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_ckd_syn_1','ckd-2-1',601100,'dev','tkc',TO_DATE(SYSDATE),
    '
    <dx_ckd>Diagnosed </dx_ckd><pers>Persistent </pers>CKD stage <ckd_stage></ckd_stage> (<cga_g></cga_g><cga_a></cga_a>) [1.1]. 
    <dx_ckd>The diagnosis on the EHR is CKD stage <dx_ckd_stage></dx_ckd_stage></dx_ckd>
    The last eGFR is <egfrlv></egfrlv> ml/min/1.73m2 (<egfrld></egfrld>)<egfr_outdated> and is outdated [1.2].</egfr_outdated>
    <egfr_decline>There is <egfr_rapid_decline>rapid </egfr_rapid_decline>progressive decline of renal function with an annual decline of <egfr_slope2></egfr_slope2>ml/min/yr [1.3]</egfr_decline> 
    '
    );
INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_ckd_recm_1','ckd-2-1',701100,'dev','tkc',TO_DATE(SYSDATE),
    '
    <egfr_outdated>Recommendation [1.2] Repeat renal function tests.</egfr_outdated>
    <dx_ckd_diff>Recommendation [1.X] Update diagnosis to CKD stage <ckd_stage></ckd_stage></dx_ckd_diff>
    '
    );
INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_ckd_footnote_1','ckd-2-1',801100,'dev','tkc',TO_DATE(SYSDATE),
    '
    <egfr_single>Note [1.1] This is based on a single egfr value on <egfrld></egfrld></egfr_single>
    <egfr_multiple>Note [1.1] This is based on <iq_egfr></iq_egfr> egfr values between <egfrfd></egfrfd> and <egfrld></egfrld></egfr_multiple>
    <egfr_outdated>Note [1.2.1] Last egfr on <egfrld></egfrld></egfr_outdated>
    <acr_outdated>Note [1.2.2] Last uACR on <acrld></acrld></acr_outdated>
    <asm_viol_3m>Note [1.2.3] Assumption violation present. +/- 20% fluctuation in last 30 days </asm_viol_3m>
    <egfr_decline>Note [1.3] Maximum eGFR of <egfr_max_v></egfr_max_v> ml/min/1.73m2 on <egfr_max_ld></egfr_max_ld>  with the most recent value being <egfrlv></egfrlv></egfr_decline>
    <iq_tier=4>Note [1.0] This was based on the presence of at least one ICPC2+ code and more than two eGFR and uACR value (Tier 4).</iq_tier=4>
    <iq_tier=3>Note [1.0] This was based on at least two eGFR and uACR values (Tier 3). </iq_tier=3>
    <iq_tier=2>Note [1.0] This was based on at least one eGFR and uACR value (Tier 3). </iq_tier=2>
    <iq_tier=1>Note [1.0] This was based on at least one eGFR or uACR value (Tier 4). </iq_tier=1>
    '
    );
INSERT INTO rman_rpt_templates (templateid,ruleblockid,placementid,environment,template_owner,effective_dt,templatehtml)
    VALUES('cd_htn_footnote_1','cd_htn_2',801100,'dev','tkc',TO_DATE(SYSDATE),
    '
    <iq_tier>Note [3.1] This is based on <iq_sbp></iq_sbp> blood pressure readings within the last 2 years</iq_tier>
    <bp_control>Note [3.3] Based on time in therapeutic range (TITR)</bp_control>

    '
    );