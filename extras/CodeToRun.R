
# ------------------------------------------------------------------------
# Settings and database credentials
# ------------------------------------------------------------------------
user <- 'todo'
password <- 'todo'
cdmDatabaseSchemaList <- 'todo'
cohortSchema <- 'todo'
oracleTempSchema <- NULL
databaseList <- 'todo' # name of the data source

dbms <- 'todo'
server <- 'todo'
port <- 'todo'
outputFolder <- paste0(getwd(),"/output")

# Optional: specify where the temporary files will be created:
# options(andromedatempdir = "")

# Connect to the server
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)

connection <- DatabaseConnector::connect(dbms = dbms,connectionDetails = connectionDetails)

# ------------------------------------------------------------------------
# Hard-coded settings
# ------------------------------------------------------------------------

## Analysis Settings
debugSqlFile <- "resp_drug_study.dsql"
cohortTable <- "resp_drug_study_cohorts"

runCreateCohorts <- TRUE
runCohortCharacterization <- TRUE
runTreatmentPathways <- TRUE
outputResults <- TRUE

study_settings <- data.frame(readr::read_csv("inst/Settings/study_settings.csv", col_types = readr::cols()))
study_settings <- study_settings[,c("param", "analysis1", "analysis2", "analysis3", "analysis4", "analysis5")]

# ------------------------------------------------------------------------
# Run the study
# ------------------------------------------------------------------------

for (sourceId in 1:length(cdmDatabaseSchemaList)) {
  cdmDatabaseSchema <- cdmDatabaseSchemaList[sourceId]
  cohortDatabaseSchema <- cohortSchema
  databaseName <- databaseList[sourceId]
  databaseId <- databaseName
  databaseDescription <- databaseName

  print(paste("Executing against", databaseName))

  outputFolderDB <- paste0(outputFolder, "/", databaseName)

  time0 <- Sys.time()
  execute(
    connection = connection,
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTable,
    oracleTempSchema = oracleTempSchema,
    outputFolder = outputFolderDB,
    databaseId = databaseId,
    databaseName = databaseName,
    runCreateCohorts = runCreateCohorts,
    runCohortCharacterization = runCohortCharacterization,
    runTreatmentPathways = runTreatmentPathways,
    outputResults = outputResults,
    study_settings = study_settings
  )
  time5 <- Sys.time()
  ParallelLogger::logInfo(paste0("Time needed to execute study for this database ", difftime(time5, time0, units = "mins")))
  
  
}

DatabaseConnector::disconnect(connection)


