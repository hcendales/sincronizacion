prompt PL/SQL Developer Export User Objects for user SINCRONIZACION@XE
prompt Created by hugo_ on viernes, 1 de abril de 2022
set define off
spool Sincronizador.log

prompt
prompt Creating table AIR_CONF_CALIDAD_AIRE
prompt ====================================
prompt
create table SINCRONIZACION.AIR_CONF_CALIDAD_AIRE
(
  objectid       VARCHAR2(100) not null,
  parametro      VARCHAR2(100) not null,
  sensor         NUMBER not null,
  estacion       VARCHAR2(100) not null,
  var_saracl     VARCHAR2(100) not null,
  fecha_creacion DATE
)
tablespace SINCRONIZACION_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table SINCRONIZACION.AIR_CONF_CALIDAD_AIRE
  add constraint VAR_SARACL primary key (VAR_SARACL, OBJECTID)
  using index 
  tablespace SINCRONIZACION_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

prompt
prompt Creating table DATOS_VAR_SARACL
prompt ===============================
prompt
create table SINCRONIZACION.DATOS_VAR_SARACL
(
  id             VARCHAR2(500),
  name           VARCHAR2(500),
  icon           VARCHAR2(500),
  unit           VARCHAR2(500),
  label          VARCHAR2(500),
  datasource     VARCHAR2(500),
  url            VARCHAR2(500),
  description    VARCHAR2(500),
  properties     VARCHAR2(500),
  tags           VARCHAR2(500),
  created_at     VARCHAR2(500),
  last_value     VARCHAR2(500),
  last_activity  NUMBER,
  type           NUMBER,
  derived_expr   VARCHAR2(500),
  values_url     VARCHAR2(500),
  fecha_creacion DATE
)
tablespace SINCRONIZACION_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table SINCRONIZACION.DATOS_VAR_SARACL
  add constraint ID primary key (ID)
  disable
  novalidate;

prompt
prompt Creating table FECHACORTE
prompt =========================
prompt
create table SINCRONIZACION.FECHACORTE
(
  fecha DATE
)
tablespace SINCRONIZACION_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

prompt
prompt Creating table VAR_SARA_CL_TIMESTAMP
prompt ====================================
prompt
create table SINCRONIZACION.VAR_SARA_CL_TIMESTAMP
(
  timestamp      NUMBER not null,
  var_saracl     VARCHAR2(100) not null,
  context        VARCHAR2(100),
  value          NUMBER,
  created_at     NUMBER,
  fecha_creacion DATE
)
tablespace SINCRONIZACION_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table SINCRONIZACION.VAR_SARA_CL_TIMESTAMP
  add constraint VAR_SARA_CL_TIMESTAMP primary key (TIMESTAMP, VAR_SARACL)
  using index 
  tablespace SINCRONIZACION_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

prompt
prompt Creating package PK_SINCRONIZACION
prompt ==================================
prompt
CREATE OR REPLACE PACKAGE SINCRONIZACION.PK_SINCRONIZACION IS

  -- =============================================
  -- Author:    Felipe Rojas
  -- Create date: 18/09/2021
  -- Description: Save data in AIR_CONF_CALIDAD_AIRE table
  PROCEDURE saveAirConfCalidadAire(P_OBJECTID   IN varchar2,
                                   P_VAR_SARACL IN varchar2,
                                   P_PARAMETRO  IN varchar2,
                                   P_SENSOR     IN number,
                                   P_ESTACION   IN varchar2,
                                   P_CODERROR   OUT number,
                                   P_MSGERROR   OUT varchar2);

  -- =============================================
  -- Author:    Felipe Rojas
  -- Create date: 21/09/21
  -- Description: Save last value of a variable in DATOS_VAR_SARACL table
  -- =============================================
  PROCEDURE saveDatosVarSaraCl(P_ID            IN varchar2,
                               P_NAME          IN varchar2,
                               P_ICON          IN varchar2,
                               P_UNIT          IN varchar2,
                               P_LABEL         IN varchar2,
                               P_DATASOURCE    IN varchar2,
                               P_URL           IN varchar2,
                               P_DESCRIPTION   IN varchar2,
                               P_PROPERTIES    IN varchar2,
                               P_TAGS          IN varchar2,
                               P_CREATED_AT    IN varchar2,
                               P_LAST_VALUE    IN varchar2,
                               P_LAST_ACTIVITY IN number,
                               P_TYPE          IN number,
                               P_DERIVED_EXPR  IN varchar2,
                               P_VALUES_URL    IN varchar2,
                               P_CODERROR      OUT number,
                               P_MSGERROR      OUT varchar2);

  -- =============================================
  -- Author:    Felipe Rojas
  -- Create date: 19/09/21
  -- Description: Create or Upate SARACL_TIMESTAMP table.
  -- =============================================
  PROCEDURE saveSaraClTimeStamp(P_VAR_SARACL IN varchar2,
                                P_TIMESTAMP  IN number,
                                P_CREATED_AT IN number,
                                P_VALUE      IN number,
                                P_CONTEXT    IN varchar2,
                                P_EXISTPAR   OUT number,
                                P_CODERROR   OUT number,
                                P_MSGERROR   OUT varchar2);

  PROCEDURE ponerCorte(P_CODERROR OUT number, P_MSGERROR OUT varchar2);


END PK_SINCRONIZACION;
/

prompt
prompt Creating package body PK_SINCRONIZACION
prompt =======================================
prompt
CREATE OR REPLACE PACKAGE BODY SINCRONIZACION.PK_SINCRONIZACION IS

  PROCEDURE saveAirConfCalidadAire(P_OBJECTID   IN varchar2,
                                   P_VAR_SARACL IN varchar2,
                                   P_PARAMETRO  IN varchar2,
                                   P_SENSOR     IN number,
                                   P_ESTACION   IN varchar2,
                                   P_CODERROR   OUT number,
                                   P_MSGERROR   OUT varchar2) AS
    EXISTVAR integer;
  BEGIN
    SELECT COUNT(VAR_SARACL)
      INTO EXISTVAR
      FROM AIR_CONF_CALIDAD_AIRE
     WHERE VAR_SARACL = P_VAR_SARACL;

    IF EXISTVAR != 0 THEN
      UPDATE AIR_CONF_CALIDAD_AIRE
         SET OBJECTID  = P_OBJECTID,
             PARAMETRO = P_PARAMETRO,
             SENSOR    = P_SENSOR,
             ESTACION  = P_ESTACION
       WHERE VAR_SARACL = P_VAR_SARACL;
    ELSE
      INSERT INTO AIR_CONF_CALIDAD_AIRE
        (OBJECTID, VAR_SARACL, PARAMETRO, SENSOR, ESTACION, FECHA_CREACION)
      VALUES
        (P_OBJECTID,
         P_VAR_SARACL,
         P_PARAMETRO,
         P_SENSOR,
         P_ESTACION,
         SYSDATE);
    END IF;

    commit;

    P_CODERROR := 0;
    P_MSGERROR := 'Operacion correcta';

  EXCEPTION
    WHEN OTHERS THEN
      P_CODERROR := SQLCODE;
      P_MSGERROR := SQLERRM;

  END saveAirConfCalidadAire;

  PROCEDURE saveDatosVarSaraCl(P_ID            IN varchar2,
                               P_NAME          IN varchar2,
                               P_ICON          IN varchar2,
                               P_UNIT          IN varchar2,
                               P_LABEL         IN varchar2,
                               P_DATASOURCE    IN varchar2,
                               P_URL           IN varchar2,
                               P_DESCRIPTION   IN varchar2,
                               P_PROPERTIES    IN varchar2,
                               P_TAGS          IN varchar2,
                               P_CREATED_AT    IN varchar2,
                               P_LAST_VALUE    IN varchar2,
                               P_LAST_ACTIVITY IN number,
                               P_TYPE          IN number,
                               P_DERIVED_EXPR  IN varchar2,
                               P_VALUES_URL    IN varchar2,
                               P_CODERROR      OUT number,
                               P_MSGERROR      OUT varchar2) AS
    P_EXISTSVAR integer;
    P_MODIFIED  integer;
  BEGIN

    SELECT COUNT(ID)
      INTO P_EXISTSVAR
      FROM DATOS_VAR_SARACL
     WHERE ID = P_ID;

    IF P_EXISTSVAR = 0 THEN
      INSERT INTO DATOS_VAR_SARACL
        (ID,
         NAME,
         ICON,
         UNIT,
         LABEL,
         DATASOURCE,
         URL,
         DESCRIPTION,
         PROPERTIES,
         TAGS,
         CREATED_AT,
         LAST_VALUE,
         LAST_ACTIVITY,
         TYPE,
         DERIVED_EXPR,
         VALUES_URL,
         FECHA_CREACION)
      VALUES
        (P_ID,
         P_NAME,
         P_ICON,
         P_UNIT,
         P_LABEL,
         P_DATASOURCE,
         P_URL,
         P_DESCRIPTION,
         P_PROPERTIES,
         P_TAGS,
         P_CREATED_AT,
         P_LAST_VALUE,
         P_LAST_ACTIVITY,
         P_TYPE,
         P_DERIVED_EXPR,
         P_VALUES_URL,
         sysdate);
    END IF;

    IF P_EXISTSVAR = 1 AND P_MODIFIED = 0 THEN
      UPDATE DATOS_VAR_SARACL
         SET NAME          = P_NAME,
             ICON          = P_ICON,
             UNIT          = P_UNIT,
             LABEL         = P_LABEL,
             DATASOURCE    = P_DATASOURCE,
             URL           = P_URL,
             DESCRIPTION   = P_DESCRIPTION,
             PROPERTIES    = P_PROPERTIES,
             TAGS          = P_TAGS,
             CREATED_AT    = P_CREATED_AT,
             LAST_VALUE    = P_LAST_VALUE,
             LAST_ACTIVITY = P_LAST_ACTIVITY,
             TYPE          = P_TYPE,
             DERIVED_EXPR  = P_DERIVED_EXPR,
             VALUES_URL    = P_VALUES_URL
       WHERE P_ID = ID;
    END IF;

    COMMIT;

    P_CODERROR := 0;
    P_MSGERROR := 'Operacion correcta';

  EXCEPTION
    WHEN OTHERS THEN
      P_CODERROR := SQLCODE;
      P_MSGERROR := SQLERRM;

  END saveDatosVarSaraCl;

  PROCEDURE ponerCorte(P_CODERROR OUT number, P_MSGERROR OUT varchar2) AS

  BEGIN

    delete from fechacorte;

    insert into fechacorte (fecha) values (sysdate);

    COMMIT;

    P_CODERROR := 0;
    P_MSGERROR := 'Operacion correcta';

  EXCEPTION
    WHEN OTHERS THEN
      P_CODERROR := SQLCODE;
      P_MSGERROR := SQLERRM;
  end ponerCorte;

  PROCEDURE saveSaraClTimeStamp(P_VAR_SARACL IN varchar2,
                                P_TIMESTAMP  IN number,
                                P_CREATED_AT IN number,
                                P_VALUE      IN number,
                                P_CONTEXT    IN varchar2,
                                P_EXISTPAR   OUT number,
                                P_CODERROR   OUT number,
                                P_MSGERROR   OUT varchar2) AS
    fecSys date;

  BEGIN
    SELECT COUNT(VAR_SARACL)
      INTO P_EXISTPAR
      FROM VAR_SARA_CL_TIMESTAMP
     WHERE TIMESTAMP = P_TIMESTAMP
       AND VAR_SARACL = P_VAR_SARACL;

    select fecha into fecSys from fechaCorte;

    IF P_EXISTPAR = 0 THEN
      INSERT INTO VAR_SARA_CL_TIMESTAMP
        (TIMESTAMP, VAR_SARACL, CONTEXT, VALUE, CREATED_AT, FECHA_CREACION)
      VALUES
        (P_TIMESTAMP,
         P_VAR_SARACL,
         P_CONTEXT,
         P_VALUE,
         P_CREATED_AT,
         fecSys);
    END IF;

    COMMIT;

    P_CODERROR := 0;
    P_MSGERROR := 'Operacion correcta';

  EXCEPTION
    WHEN OTHERS THEN
      P_CODERROR := SQLCODE;
      P_MSGERROR := SQLERRM;

  END saveSaraClTimeStamp;

end PK_SINCRONIZACION;
/


prompt Done
spool off
set define on
