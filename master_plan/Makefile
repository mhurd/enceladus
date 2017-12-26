DB=enceladus
BUILD=${CURDIR}/build.sql
SCRIPTS=${CURDIR}/scripts
CSV='${CURDIR}/data/master_plan.csv'
TARGET_CSV=/tmp/master_plan.csv
MASTER=${SCRIPTS}/import.sql
NORMALISE=${SCRIPTS}/normalise.sql
all:normalise
	psql -h 127.0.0.1 -p 5432 -U pi ${DB} -f ${BUILD}
master:
	@cat ${MASTER} >> ${BUILD}
import:master
	@kubectl cp ${CSV} postgres-7dx4h:${TARGET_CSV}
	@echo "COPY import.master_plan FROM '${TARGET_CSV}' WITH DELIMITER ',' HEADER CSV;" >> ${BUILD}
normalise:import
	@cat ${NORMALISE} >> ${BUILD}
clean:
	@rm -f ${BUILD}
