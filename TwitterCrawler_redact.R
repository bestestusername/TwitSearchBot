##========================================================##
##                                                        ##
##   Twitter Crawler                                      ##
##   Acies Lumen 2020, Boston, MA                         ##
##   www.AciesLumen.com                                   ##
##                                                        ##
##   Adam Ragozzino                                       ##
##     Email: adam@acieslumen.com                         ##
##   Twitter: @adamragozzino                              ##
##   Used: R Version 4.0.2, Windows 10(x64)               ##
##   In RStudio v 1.3.1073                                ##
##========================================================##

# CONTENTS
#
#   1. Libraries
#   2. Create Keyring to store passwords  
#   3. Set working directory
#   4. Define the Variables
#   5. Set Twitter Credentials
#   6. Create Search Function 
#   7. Write to file 
#   8. Emai file


# 1 Load the necessary libraries
library(xml2)
library(xlsx)
library(keyring)
library(Rtweet)
library(twitteR)
library(mailR )

# 2 Use Keyring to store email username with password
  kr_service <- "email"
  kr_name <- "AciesLumen"
  kr_username <- "adam@acieslumen.com"

  # Create a keyring and add an entry using the variables above
  kb <- keyring::backend_file$new()
  
  # Prompt for the keyring password, used to unlock keyring
  kb$keyring_create(kr_name)
  
  # Prompt for the credential to be stored in the keyring
  kb$set(kr_service, username=kr_username, keyring=kr_name)
  
  # Lock the keyring
  kb$keyring_lock(kr_name)


# 3 Set Working Directory to the File Location
DIR <- "A:/Data/Crawler"
setwd(DIR)
getwd()

# 4 Define the input variables
  #Search Variables
  SrchTerm = "violence+#Mali"
  SrchType = "recent"
  SrchStart = "2020-08-20"
  SrchEnd = "2020-08-31"

  #File Variables
  FileType = "xlsx"
  FileLoc = DIR
  FileName = "Mali"
  TabName = paste(substr(SrchTerm,1,8), Sys.Date())

  #Email Variables
  EmailTo ="info@acieslumen.com"
  EmailSubject = paste(Sys.Date(),"Twitter Results")

# 5 Set Twitter credentials
  setup_twitter_oauth("notthereal1", "getyourowntoken", 
                    access_token="youraccesstokenhere", 
                    access_secret="yoursecretaccesstoken")

  
# 6 Create Twitter Search Function
  twSearch <- function(term, type, start_dt, end_dt) 
  {
    searchTwitteR(term, 
                resultType= type, 
                since=start_dt, 
                until=end_dt, 
                #geocode=coord, #'Lat, Long, Radius'
                lang=NULL
    ) 
  }

  # Run the search
  twResults <-twSearch(SrchTerm, SrchType, SrchStart, SrchEnd)
  #----------------------------------------------------------------------


# 7 Export the results to CSV OR XLSX file
#----------------------------------------------------------------------
if (FileType == "csv") {
  write.csv(twListToDF(twResults), file = file.path(FileLoc,FileName))
  } else {
#OR Xlsx Output
  write.xlsx(
    x = twListToDF(twResults),
    # Write xlsx with multiple sheets
    file = file.path(FileLoc, paste0(FileName,".", FileType)),
    sheetName = TabName,
    append = TRUE
  )
}


# 8 Mail the file
send.mail(from = "adam@acieslumen.com",
          to = EmailTo,
          subject = EmailSubject,
          body = paste0("File ",
                        file.path(FileLoc,paste0(FileName,".", FileType)),
                        " was created with the following parameters: ",
                        "Searched for ", SrchTerm , " in ", SrchType, 
                        " tweets. Between ", SrchStart, " and ", SrchEnd),
          smtp = list(host.name = "mail.acieslumen.com",
                      port = 465,
                      user.name = "adam@acieslumen.com",
                      passwd = keyring::backend_file$new()$get(service = kr_service, user = kr_username, keyring = kr_name),
                      ssl = TRUE),
          authenticate = TRUE,
          Delay = TRUE,
          send = TRUE,
          attach.files = file.path(FileLoc,paste0(FileName,".", FileType)),
          #file.names = c("Download log.log", "Upload log.log", "DropBox File.rtf"), # optional parameter
          #file.descriptions = c("Description for download log", "Description for upload log", "DropBox File"), # optional parameter
          debug = FALSE)
