DB=enceladus
BUILD=${CURDIR}/build.sql
SCRIPTS=${CURDIR}/scripts
CSV='${CURDIR}/data/master_plan.csv'
TARGET_CSV=/mnt/common/workspace/enceladus/master_plan/data/master_plan.csv
MASTER=${SCRIPTS}/import.sql
NORMALISE=${SCRIPTS}/normalise.sql
all:normalise
	PGPASSWORD=pi psql -h 10.0.0.1 -p 30000 -U pi -w ${DB} -f ${BUILD}
master:
	@cat ${MASTER} >> ${BUILD}
import:master
	@echo "COPY import.master_plan FROM '${TARGET_CSV}' WITH DELIMITER ',' HEADER CSV;" >> ${BUILD}
normalise:import
	@cat ${NORMALISE} >> ${BUILD}
clean:
	@rm -f ${BUILD}
