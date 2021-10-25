CREATE TABLE TB_M_PARENT_GENTANI_HEADER_HIKIATE
(
    PARENT_CD VARCHAR(23) NOT NULL,
    PROC_USAGE_CD VARCHAR(5) NOT NULL,
    GENTANI_HEADER_TYPE VARCHAR(3) NOT NULL,
    GENTANI_HEADER_CD VARCHAR(23) NOT NULL,
    VALID_DT_FR DATETIME NOT NULL,
    VALID_DT_TO DATETIME NOT NULL,
    MULTIPLY_USAGE INT NOT NULL,
    CREATED_BY VARCHAR(20) NOT NULL,
    CREATED_DT DATETIME NOT NULL,
    CHANGED_BY VARCHAR(20),
    CHANGED_DT DATETIME,

    CONSTRAINT PK_TB_M_PARENT_GENTANI_HEADER_HIKIATE PRIMARY KEY (PARENT_CD, PROC_USAGE_CD, GENTANI_HEADER_TYPE, GENTANI_HEADER_CD, VALID_DT_FR)
)