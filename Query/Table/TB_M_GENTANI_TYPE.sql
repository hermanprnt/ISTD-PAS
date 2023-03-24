CREATE TABLE TB_M_GENTANI_TYPE
(
    PROC_USAGE_CD VARCHAR(5) NOT NULL,
    GENTANI_HEADER_TYPE VARCHAR(3) NOT NULL,
    [DESCRIPTION] VARCHAR(50) NOT NULL,
    CREATED_BY VARCHAR(20) NOT NULL,
    CREATED_DT DATETIME NOT NULL,
    CHANGED_BY VARCHAR(20),
    CHANGED_DT DATETIME,

    CONSTRAINT PK_TB_M_GENTANI_TYPE PRIMARY KEY (PROC_USAGE_CD, GENTANI_HEADER_TYPE)
)
