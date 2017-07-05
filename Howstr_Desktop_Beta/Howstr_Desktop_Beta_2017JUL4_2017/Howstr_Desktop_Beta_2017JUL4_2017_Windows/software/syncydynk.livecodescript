script "syncydynk"
-- relies on cAPIkey, cEmail, and cToken saved when stack closes
local sMode

command authButtMouseUp
   authorizeMe
end authButtMouseUp

command uploadButtMouseUp
   uploadMe
end uploadButtMouseUp

command checkForkButtMouseUp
   checkForMe
end checkForkButtMouseUp

command downloadForkButtMouseUp
   downloadMe
end downloadForkButtMouseUp

on repoWranglerLog pMsg
   --    put the cLog of me into tLog
   put the cLog of stack "repowrangler" into tLog
   filter tLog without empty
   put cr & "-" && the internet date && "-" && pMsg after tLog
   --    set the cLog of me to tLog
   set the cLog of stack "repowrangler" to tLog
   --    put tLog into field "logField" of me
   put tLog into field "logField" stack "repowrangler"
   Set The VScroll Of Field "logField" stack "repowrangler" To (The Effective TextHeight Of Field "logField" stack "repowrangler") * (The Number Of Lines In Field "logField" stack "repowrangler")
end repoWranglerLog

------------------------------------------------------------ AUTHORIZATION ------------------------------------
-- relies on cAPIkey, cEmail, and cToken saved when stack closes
-- local sMode

on authorizeMe
   put the cMode of stack "repowrangler" into sMode   
   put "working" into field "statusLabel" stack "repowrangler"
   -- use email and key from fields
   -- fall back to email and key from storage
   -- if all empty, just exit
   --    repoWranglerLog("started authentication, mode: " & sMode)
   switch sMode
      case "test"
         repoWranglerLog("*** started version-test authentication ***")
         set the visible of widget "testAuthIcon" stack "repowrangler" to false
         put field "testKeyField" stack "repowrangler" into tKeyField
         put field "testEmailField" stack "repowrangler" into tEmailField
         put the cTestKey of stack "repowrangler" into tKey
         put the cTestEmail of stack "repowrangler" into tEmail
         put false into tChanged
         if tKeyField is not tKey then 
            put true into tChanged
            set the cTestToken of stack "repowrangler" to empty
            put tKeyField into tKey
            set the cTestKey of stack "repowrangler" to tKey
            repoWranglerLog("new version-test API key saved")
         end if
         if tEmailField is not tEmail then 
            put true into tChanged
            set the cTestToken of stack "repowrangler" to empty
            put tEmailField into tEmail
            set the cTestEmail of stack "repowrangler" to tEmail
            repoWranglerLog("new registered version-test email saved")
         end if
         if tKey is empty then 
            repoWranglerLog("version-test API key missing")
            exit authorizeMe
         end if
         if tEmail is empty then 
            repoWranglerLog("registered version-test email missing")
            exit authorizeMe
         end if
         put the cTestToken of stack "repowrangler" into tToken
         if tToken is empty then
            -- api_auth
            repoWranglerLog("requesting new version-test token")
            put getNewToken(tKey,tEmail,sMode) into tToken
            set the cTestToken of stack "repoWrangler" to tToken
         else -- tToken not empty
            -- test tToken with auth_echo
            repoWranglerLog("testing version-test token")
            if testToken(tToken,sMode) then
               repoWranglerLog("version-test token confirmed")
               set the cTestToken of stack "repoWrangler" to tToken
            else
               repoWranglerLog("version-test token failed")
               set the cTestToken of stack "repoWrangler" to empty
            end if
            -- if good, then leave alone
            -- if bad, then empty tToken and api_auth
            if tToken is empty then
               repoWranglerLog("requesting new version-test token")
               put getNewToken(tKey,tEmail,sMode) into tToken
            end if
         end if -- tToken empty
         -- if tToken still empty then exit, auth failed
         if tToken is empty then 
            --             answer "could not authenticate version-test"
            repoWranglerLog("version-test token empty")
            set the visible of widget "testAuthIcon" of stack "repoWrangler" to false
            exit authorizeMe
         end if
         repoWranglerLog("version-test token confirmed")
         set the visible of widget "testAuthIcon" of stack "repoWrangler" to true
         break
      case "live" ----------------------------------------------------live----------------------
         repoWranglerLog("started live authentication")
         set the visible of widget "liveAuthIcon" stack "repowrangler" to false
         put field "liveKeyField" stack "repowrangler" into tKeyField
         put field "liveEmailField" stack "repowrangler" into tEmailField
         put the cLiveKey of stack "repowrangler" into tKey
         put the cLiveEmail of stack "repowrangler" into tEmail
         put false into tChanged
         if tKeyField is not tKey then 
            put true into tChanged
            set the cLiveToken of stack "repowrangler" to empty
            put tKeyField into tKey
            set the cLiveKey of stack "repowrangler" to tKey
            repoWranglerLog("new live API key saved")
         end if
         if tEmailField is not tEmail then 
            put true into tChanged
            set the cLiveToken of stack "repowrangler" to empty
            put tEmailField into tEmail
            set the cLiveEmail of stack "repowrangler" to tEmail
            repoWranglerLog("new live registered email saved")
         end if
         if tKey is empty then 
            repoWranglerLog("live API key missing")
            exit authorizeMe
         end if
         if tEmail is empty then 
            repoWranglerLog("live registered email missing")
            exit authorizeMe
         end if
         put the cLiveToken of stack "repowrangler" into tToken
         if tToken is empty then
            -- api_auth
            repoWranglerLog("requesting new live token")
            put getNewToken(tKey,tEmail,sMode) into tToken
            set the cLiveToken of stack "repoWrangler" to tToken
         else -- tToken not empty
            -- test tToken with auth_echo
            --             put testToken(tToken,sMode) into tToken
            if testToken(tToken,sMode) then
               repoWranglerLog("live token confirmed")
               set the cLiveToken of stack "repoWrangler" to tToken
            else
               repoWranglerLog("live token failed")
               set the cLiveToken of stack "repoWrangler" to empty
            end if
            -- if good, then leave alone
            -- if bad, then empty tToken and api_auth
            if tToken is empty then
               repoWranglerLog("requesting new live token")
               put getNewToken(tKey,tEmail,sMode) into tToken
            end if
         end if -- tToken empty
         -- if tToken still empty then exit, auth failed
         if tToken is empty then 
            --             answer "could not authenticate live"
            repoWranglerLog("live token empty")
            set the visible of widget "liveAuthIcon" of stack "repoWrangler" to false
            exit authorizeMe
         end if
         repoWranglerLog("live token confirmed")
         set the visible of widget "liveAuthIcon" of stack "repoWrangler" to true
         break
   end switch
   
   put "done" into field "statusLabel" stack "repowrangler"
   --    close stack "repowrangler"
end authorizeMe

function getNewToken pKey,pEmail,pMode
   --    put the cAPIkey of stack "repowrangler" into tDis["key"]
   --    put the cEmail of stack "repowrangler" into tDis["email"]
   put pKey into tDis["key"]
   put pEmail into tDis["email"]
   set the httpHeaders to "Content-Type: application/json" 
   put jsonfromarray(tDis) into tPayload
   if pMode is "test" then
      post tPayload to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/api_auth"
   else
      post tPayload to URL "https://howstr.bubbleapps.io/api/1.0/wf/api_auth"
   end if
   put arrayfromjson(it) into tResponseA
   --    put tResponseA["response"] into tResponseA
   put tResponseA["response"]["user_id"] into tUser_ID
   put empty into tToken
   put tResponseA["response"]["token"] into tToken
   --    set the cToken of stack "repowrangler" to tToken -- ! set cToken
   return tToken
end getNewToken

function testToken pToken,pMode
   put "not important" into tDis["whatever"]
   set the httpHeaders to "Content-Type: application/json" & cr & "Authorization: Bearer" && pToken
   put jsonfromarray(tDis) into tPayload
   if pMode is "test" then
      post tPayload to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/api_echo"
   else
      post tPayload to URL "https://howstr.bubbleapps.io/api/1.0/wf/api_echo"
   end if
   if it is "authorized" then
      --    put tResponseA["response"]["token"] into tToken
      --       set the cToken of stack "repowrangler" to pToken -- ! set cToken
      return true
   else
      --       put empty into pToken
      --       set the cToken of stack "repowrangler" to pToken
      return false
   end if
   --    return pToken
end testToken
--------------------------------------------------------- END AUTHORIZATION ------------------------------------

---------------------------------------------------------- UPLOAD --------------------------------------------------
-- relies on cAPIkey, cEmail, and cToken saved when stack closes
-- local sMode
on uploadMe   
   saveButtMouseUp -- stack lazydogpile
   -- was the current project saved or not?
   if the cSaveStatus of stack "repoWrangler" is "unsaved" then 
      repoWranglerLog("current project has unsaved changes; save before uploading")
      exit uploadMe
   end if
   uploadPrep -- stack lazydogpile
   
   put the cMode of stack "repowrangler" into sMODE
   put "working" into field "statusLabel" stack "repowrangler"
   put the cPayload of stack "repowrangler" into tPayloadA
   --    repoWranglerLog("begin upload in mode:" && sMode)
   if sMode is "test" then
      repoWranglerLog("*** started upload to Howstr.com/version-test repository ***")
   else
      repoWranglerLog("*** started upload to Howstr.com repository ***")
   end if
   
   -- create zip
   --    put createZip(tPayloadA["project"]["filepath"]) into tZipFile -- will be deleted after upload
   --    put URL ("binfile:" & tZipFile) into tBinZip
   --    put base64encode(tBinZip) into tPayloadA["project"]["how_zip"] -- encoded for upload
   --    repoWranglerLog("temp zip archive created and encoded")
   
   -- grab how file
   put giveMeTheHowFile() into tReq["newProjectFolder"]
   put loadNewProject(tReq) into tFileData
   put tFileData["data"] into tPayloadA["project"]["how_array"]
   
   -- create new project
   put "project" into tMission["type"]
   put tPayloadA["project"] into tMission["payload"]
   --    put empty into tMission["payload"]["filepath"]
   --    put dispatchPayload(tMIssion) into tPayloadA["project"]["bubble_id"]
   put dispatchPayload(tMIssion) into tFinal
   if tFinal is "error" then
      repoWranglerLog("error creating project, ending upload")
      put "done" into field "statusLabel" stack "repowrangler"
      exit uploadMe
   else
      put tFinal into tPayloadA["project"]["bubble_id"]
   end if
   
   --    put dispatchPayload(tMIssion) into tPayloadA["project"]["bubble_id"]
   --    put tGotBack into tPayloadA["project"]["bubble_id"]
   repoWranglerLog("new project version created in Howstr.com repository")
   
   -- nest action(s) and node(s)
   set itemdelimiter to comma
   put the keys of tPayloadA["action"] into tKeys
   put the number of lines of tKeys into tTotalKeys
   repeat with tCounter = 1 to the number of lines of tKeys
      repoWranglerLog("step" && tCounter & "/" & tTotalKeys && "uploading")
      -- create new action
      -- double link action and project
      put empty into tMission
      put "action" into tMission["type"]
      put tPayloadA["project"]["bubble_id"] into tMission["payload"]["project"]
      put tCounter into tMission["payload"]["step_num"]
      --       put dispatchPayload(tMIssion) into tPayloadA["action"][tCounter]["bubble_id"]
      put dispatchPayload(tMission) into tFinal
      if tFinal is "error" then
         repoWranglerLog("error creating action, ending upload")
         put "done" into field "statusLabel" stack "repowrangler"
         exit uploadMe
      else
         put tFinal into tPayloadA["action"][tCounter]["bubble_id"]
      end if
      
      -- create nodes and/or link existing nodes in action's input(s), thruput, output(s)
      put empty into tNodesMade
      -- only one thruput, which can't have been made before cuz change nodes are unique
      put tPayloadA["action"][tCounter]["thruput"] into tNode
      put empty into tMission
      put "node" into tMission["type"]
      put tPayloadA["node"][tNode] into tMission["payload"]
      put "thruput" into tMission["payload"]["put"]
      put tPayloadA["action"][tCounter]["bubble_id"] into tMission["payload"]["action"]
      put tPayloadA["project"]["bubble_id"] into tMission["payload"]["project"]
      put dispatchPayload(tMIssion) into tFinal
      if tFinal is "error" then
         repoWranglerLog("error creating node, ending upload")
         put "done" into field "statusLabel" stack "repowrangler"
         exit uploadMe
      else
         put tFinal into tPayloadA["node"][tNode]["bubble_id"]  
      end if
      
      set the itemdelimiter to comma
      put tNode into item (the number of items of tNodesMade)+1 of tNodesMade
      
      -- inputs & outputs can be reused
      repeat for each word tPut in "inputs outputs"
         repeat for each key tNode in tPayloadA["action"][tCounter][tPut]
            put empty into tMission
            put tPut into tMission["payload"]["put"]
            put tPayloadA["node"][tNode]["bubble_id"] into tMission["payload"]["node"]
            put tPayloadA["action"][tCounter]["bubble_id"] into tMission["payload"]["action"]
            put tPayloadA["project"]["bubble_id"] into tMission["payload"]["project"]
            set the itemdelimiter to comma
            if tNode is among the items of tNodesMade then
               put "link" into tMission["type"]
               put dispatchPayload(tMIssion) into tWhatever
               if tWhatever is "no success" then
                  put "done" into field "statusLabel" stack "repowrangler"
                  repoWranglerLog("creation failure, please try again")
                  exit uploadMe
               end if
            else -- node needs to be made
               put "node" into tMission["type"]
               put tPayloadA["node"][tNode]["title"] into tMission["payload"]["title"]
               put tPayloadA["node"][tNode]["memo"] into tMission["payload"]["memo"]
               put tPayloadA["node"][tNode]["figure"] into tMission["payload"]["figure"]
               put tPayloadA["node"][tNode]["record"] into tMission["payload"]["record"]
               put tPayloadA["action"][tCounter][tPut][tNode] into tMission["payload"]["weight_put"]
               if tNode is among the keys of tPayloadA["project"]["resources"] then
                  put tPayloadA["project"]["resources"][tNode] into tMission["payload"]["weight_resource"]
               end if
               if tNode is among the keys of tPayloadA["project"]["results"] then
                  put tPayloadA["project"]["results"][tNode] into tMission["payload"]["weight_result"]
               end if
               put dispatchPayload(tMIssion) into tPayloadA["node"][tNode]["bubble_id"]
               if tPayloadA["node"][tNode]["bubble_id"] is "no success" then
                  put "done" into field "statusLabel" stack "repowrangler"
                  repoWranglerLog("creation failure, please try again")
                  exit uploadMe
               end if               
               set the itemdelimiter to comma
               put tNode into item (the number of items of tNodesMade)+1 of tNodesMade
            end if
         end repeat
      end repeat
   end repeat
   repoWranglerLog(tCounter && "steps created in Howstr.com repository")
   
   --    delete file tZipFile
   put "done" into field "statusLabel" stack "repowrangler"
   --    repoWranglerLog("temp zip archive deleted")
   repoWranglerLog("upload completed")
   --    close stack "repowrangler"
end uploadMe

function dispatchPayload pMsn
   repoWranglerLog("upload running...")
   put pMsn["type"] into tType
   put pMsn["payload"] into tPLA
   switch sMode
      case "live"
         put the cLiveKey of stack "repowrangler" into tKey
         put the cLiveEmail of stack "repowrangler" into tEmail
         put the cLiveToken of stack "repowrangler" into tToken
         break
      case "test"
         put the cTestKey of stack "repowrangler" into tKey
         put the cTestEmail of stack "repowrangler" into tEmail
         put the cTestToken of stack "repowrangler" into tToken
         break
   end switch
   --    put the cAPIkey of stack "repowrangler" into tKey
   --    put the cEmail of stack "repowrangler" into tEmail
   --    put the cToken of stack "repowrangler" into tToken
   
   -- overwrite [figure] as required
   if tPLA["figure"] is not empty then
      put tPLA["figure"] into tFigure
      put URL ("binfile:" & tFigure) into tImage
      put base64encode(tImage) into tPLA["figure"]["contents"]
      set the itemDelimiter to "/"
      put item -1 of tFigure into tPLA["figure"]["filename"]
      put tPLA["figure"]["filename"] into tPLA["figure_name"]
      set the itemdelimiter to comma
      put "false" into tPLA["figure"]["private"]
   end if
   -- convert payload into JSON
   put jsonfromarray(tPLA) into tPLAJSON
   put tPLAJSON into tWat["payload"]
   put tType into tWat["type"]
   set the httpHeaders to "Content-Type: application/json" & cr & "Authorization: Bearer" && tToken
   
   put empty into tForReturn
   repeat for 3 times
      put dispatchPayload2(tWat) into tWhatNowA
      switch
         case tWhatNowA["message"] contains "error"
            repoWranglerLog("message contains error")
            put "error" into tForReturn
            break
         case tWhatNowA["statusCode"] is "400"
            replace cr with "" in tWhatNowA["body"]
            repoWranglerLog("error 400" && tWhatNowA["body"])
            put "error" into tForReturn
            break
         case tWhatNowA["statusCode"] is "401"
            repoWranglerLog("error 401 authentication")
            put "error" into tForReturn
            break
         case tWhatNowA["status"] is not "success"
            repoWranglerLog("message does not contain success")
            put "error" into tForReturn
            break
         default
            put tWhatNowA["response"]["result"] into tForReturn
            exit repeat
      end switch
   end repeat
   return tForReturn
   
   --    put dispatchPayload2(tWat) into tWhatNowA
   --    if tWhatNowA["statusCode"] is "400" then
   --       put tWhatNowA["body"] into tMessage
   --       replace cr with "" in tMessage
   --       repoWranglerLog("API returned 400, body: " & tMessage)
   --       return "didn't work"
   --    else if tWhatNowA["statusCode"] is "401" then
   --       --       return "could not authenticate"      
   --       repoWranglerLog("could not authenticate")
   --       return "didn't work"
   --    else if tWhatNowA["message"] contains "error" then
   --       --       return "API timed out. Try again later."
   --       repoWranglerLog("timed out, try again later")
   --       return "didn't work"
   --    else if tWhatNowA["status"] is not "success" then
   --       repoWranglerLog("no success, try again")
   --       return "no success"
   --    else
   --       return tWhatNowA["response"]["result"]
   --    end if
end dispatchPayload

function dispatchPayload2 pWat  
   put pWat["payload"] into tPLAJSON
   put pwat["type"] into tType
   switch tType
      case "node"
         if sMODE is "test" then
            post tPLAJSON to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/new_node"
         else
            post tPLAJSON to URL "https://howstr.bubbleapps.io/api/1.0/wf/new_node"
         end if
         put arrayfromjson(it) into tReturnA
         break
      case "action"
         if sMODE is "test" then
            post tPLAJSON to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/new_action"
         else
            post tPLAJSON to URL "https://howstr.bubbleapps.io/api/1.0/wf/new_action"
         end if
         put arrayfromjson(it) into tReturnA
         break
      case "project"
         if sMODE is "test" then
            post tPLAJSON to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/new_project"
         else
            post tPLAJSON to URL "https://howstr.bubbleapps.io/api/1.0/wf/new_project"
         end if
         put arrayfromjson(it) into tReturnA
         break
      case "link"
         if sMODE is "test" then
            post tPLAJSON to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/link_node_action"
         else
            post tPLAJSON to URL "https://howstr.bubbleapps.io/api/1.0/wf/link_node_action"
         end if
         put arrayfromjson(it) into tReturnA
         break
   end switch
   return tReturnA
end dispatchPayload2

function createZip pFilePath
   set itemdelimiter to "/"
   put item -1 of pFilePath into tProjName
   put pFilePath into tFolderPath
   put empty into item -1 of tFolderPath
   --    set itemdelimiter to comma
   replace ".how" with "" in tProjName
   put urlencode(tProjName) into tURLname
   --    put tFolderPath & tURLname & ".zip" into tArchivePath
   put the temporary folder & "/howstr-upload-temp.zip" into tArchivePath
   
   repoWranglerLog("zipping" && tFolderPath && "for upload")
   put the stacksinuse into tStacksInUse
   revZipOpenArchive tArchivePath, "write"
   AddFolderToArchive tArchivePath, tFolderPath
   revZipCloseArchive tArchivePath
   
   return tArchivePath
end createZip
------------------------------------------------------- END UPLOAD ----------------------------------------

--------------------------------------------------------- CHECK FORK --------------------------------------
-- relies on cAPIkey, cEmail, and cToken saved when stack closes
-- local sMODE
on checkForMe
   repoWranglerLog("*** begin checking Howstr.com for latest fork ***")
   --    put "test" into sMODE -- ! use this to manually send data to Bubble's version-test; comment out to send to live
   put the cMode of stack "repowrangler" into sMODE
   --    put "live" into sMODE
   
   put "working" into field "statusLabel" stack "repowrangler"
   -- use email and key from fields
   -- fall back to email and key from storage
   switch sMode
      case "live"
         put the cLiveToken of stack "repoWrangler" into tToken
         repoWranglerLog("mode:" && sMode)
         break
      case "test"
         put the cTestToken of stack "repoWrangler" into tToken
         repoWranglerLog("mode:" && sMode)
         break
   end switch
   --    put the cToken of stack "repowrangler" into tToken
   if tToken is empty then 
      put "please authenticate" into field "statusLabel" stack "repowrangler"
      repoWranglerLog(sMode && "token empty")
      exit checkForMe
   end if
   
   put check4fork(tToken) into tResult
   
   put "done" into field "statusLabel" stack "repowrangler"
   --    close stack "repowrangler"
end checkForMe

function check4fork pToken
   -- [email]=email
   -- [key]=api key
   put "not important" into tDis["whatever"]
   --    set the httpHeaders to "Content-Type: application/json" 
   --    put the cToken of stack "repowrangler" into tToken
   set the httpHeaders to "Content-Type: application/json" & cr & "Authorization: Bearer" && pToken
   put jsonfromarray(tDis) into tPayload
   if sMode is "test" then
      post tPayload to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/check_fork"
   else
      post tPayload to URL "https://howstr.bubbleapps.io/api/1.0/wf/check_fork"
   end if
   put it into tID
   if tID is empty then
      if sMode is "live" then
         repoWranglerLog("no fork found in Howstr.com profile")
      else
         repoWranglerLog("no fork found in Howstr.com/version-test profile")
      end if
   else
      if sMode is "live" then
         repoWranglerLog("fork found in Howstr.com profile")
         put tID into field "liveForkField" stack "repowrangler"
      else
         repoWranglerLog("fork found in Howstr.com/version-test profile")
         put tID into field "testForkField" stack "repowrangler"
      end if
   end if
   --    return pToken
end check4fork
-------------------------------------------------------- END CHECK FORK ---------------------------------------

---------------------------------------------------------- GET FORK ------------------------------------------------
-- relies on cAPIkey, cEmail, and cToken saved when stack closes
-- local sMODE
on downloadMe
   put the cMode of stack "repowrangler" into sMODE
   if sMode is "live" then
      repoWranglerLog("begin downloading latest fork from Howstr.com profile")
   else
      repoWranglerLog("begin downloading latest fork from Howstr.com/version-test profile")
   end if
   
   put "working" into field "statusLabel" stack "repowrangler"
   -- use email and key from fields
   -- fall back to email and key from storage
   switch sMode
      case "live"
         put the cLiveToken of stack "repoWrangler" into tToken
         break
      case "test"
         put the cTestToken of stack "repoWrangler" into tToken
         break
   end switch
   --    put the cToken of stack "repowrangler" into tToken
   if tToken is empty then 
      put "please authenticate" into field "statusLabel" stack "repowrangler"
      repoWranglerLog("token empty")
      exit downloadMe
   end if
   
   put retrieveFork(tToken) into tHowFolderPath
   put "done" into field "statusLabel" stack "repowrangler"
   
   answer "Open the project that was just downloaded?" with "Yes" or "No"
   if it is "yes" then 
      loadButtMouseUp tHowFolderPath
   end if
   
end downloadMe

function retrieveFork pToken
   put "not important" into tDis["whatever"]
   set the httpHeaders to "Content-Type: application/json" & cr & "Authorization: Bearer" && pToken
   put jsonfromarray(tDis) into tPayload
   repoWranglerLog("downloading .how file")
   if sMode is "test" then
      post tPayload to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/get_fork"
   else
      post tPayload to URL "https://howstr.bubbleapps.io/api/1.0/wf/get_fork"
   end if
   put arrayfromjson(it) into tResponseA   
   put tResponseA["response"]["how_array"] into tHow -- livecode array in json format
   put tResponseA["response"]["to_id"] into tNewID -- unique_id
   put tResponseA["response"]["from_id"] into tOldID -- unique_id
   --    put tResponseA["response"]["img_list"] into tImgList -- list of unique_ids for bubble's database
   put tResponseA["response"]["img_name_list"] into tImgNameList -- list of unique_ids for bubble's database
   put tResponseA["response"]["img_url_list"] into tImgUrlList
   
   --    put tResponseA["response"]["how_zip"] into tZipFile64
   --    repoWranglerLog("decoding zip archive")
   --    put base64decode(tZipFile64) into tZipFile
   
   put tResponseA["response"]["name"] into tOldName -- title
   put specialFolderPath("documents") into tDocsPath
   ask file "Give this project a folder name (the old fork was called: " & tOldName & ")"  with tDocsPath
   if the result is "cancel" then
      put tDocsPath & "/" & "Howstr project fork" && the long system time into tNewFolder
      repoWranglerLog("no project name provided; using default")
   else
      put it into tNewFolder
      repoWranglerLog("project name provided:" && it)
   end if
   set itemdelimiter to "/"
   put item -1 of tNewFolder into tHowFileNewName
   if there is not a folder tNewFolder then create folder tNewFolder
   
   --    put tUnzipFold & "/temp.zip" into tZipTemp
   --    put the temporary folder & "/howstr-fork-temp.zip" into tZipTemp
   --    put tZipFile into URL ("binfile:" & tZipTemp)
   --    put the result into tResult
   -- might need to extract to one folder higher, then change folder name
   --    put the stacksinuse into tStacksInUse
   --    revZipOpenArchive tZipTemp, "read"
   --    DecompressArchiveToFolder tZipTemp, tUnzipFold
   --    revZipCloseArchive tZipTemp
   --    delete file tZipTemp
   --    repoWranglerLog("zip archive extraction complete")
   --    put the result into tResult
   --    set the defaultfolder to tUnzipFold
   --    put the files into tFiles
   --    repeat for each line tFile in tFiles
   --       if tFile contains ".how" then
   --          put tFile into tReplaceMe
   --       end if
   --    end repeat
   
   --    rename file tReplaceMe to tHowFileNewName & ".how"
   
   put tNewFolder & "/" & tHowFileNewName & ".how" into tHowPath
   replace cr with "n" in tHow -- ! escaped newline was becoming \+actual newline
   put arrayfromjson(tHow) into tHowA
   put tNewID into tHowA[0]["UUID"]
   put tHowPath into tHowA[0]["filepath"]
   put jsonfromarray(tHowA) into tHowNew
   put tHowNew into URL ("binfile:" & tHowPath)
   repoWranglerLog("new UID and filepath recorded in .how file")
   
   set itemdelimiter to comma
   put the number of items of tImgNameList into tImgListTotal
   --    put 0 into tCounter
   repeat with tCounter = 1 to tImgListTotal
      put item tCounter of tImgNameList into tFilename
      put item tCounter of tImgUrlList into tServerPath
      put "https:" & tServerPath into tServerPath
      put tNewFolder & "/" & tFilename into tNewFile
      set the httpHeaders to empty
      put URL tServerPath into URL ("binfile:" & tNewFile)
   end repeat
   
   --    repeat for each item tImgUrl in tImgUrlList
   --       put "https:" & tImgUrl into tImgUrl
   --       --       replace "//" with "" in tImgUrl
   --       --       put tCounter + 1 into tCounter
   --       --       repoWranglerLog("downloading image" && tCounter & "/" & tImgListTotal)
   --       --       load URL tImgUrl with imageDownloadComplete(tImgUrl,tNewFolder)
   
   --       -- change image filename
   --       -- ? back to original
   --       -- ? to match new
   --       set itemdelimiter to "/"
   --       put item -1 of tImgUrl into tImgName
   --       set itemdelimiter to comma
   --       put tNewFolder & "/" & tImgName into tNewFile
   --       put the httpHeaders into tVisible
   --       set the httpHeaders to empty
   --       put the httpHeaders into tVisible
   --       --       libURLDownloadToFile tImgUrl,tNewFile,"finished"
   --       --       put URL tImgUrl into URL ("binfile:" & tNewFile)
   --       try
   --          --          load tImgUrl with message "checkDownloads"
   --          --          libURLDownloadToFile tImgUrl,tNewFile,"checkDownloads"
   --          put URL tImgUrl into URL ("binfile:" & tNewFile)
   --       catch myErr
   --          answer myErr
   --       end try
   --    end repeat
   
   --    repeat for each item tImg in tImgList
   --       put tCounter + 1 into tCounter
   --       repoWranglerLog("downloading image" && tCounter & "/" & tImgListTotal)
   --       lock screen
   --       put tImg into tDis["img_thing"]
   --       set the httpHeaders to "Content-Type: application/json" & cr & "Authorization: Bearer" && pToken
   --       put jsonfromarray(tDis) into tPayload
   --       if sMode is "test" then
   --          post tPayload to URL "https://howstr.bubbleapps.io/version-test/api/1.0/wf/get_img"
   --       else
   --          post tPayload to URL "https://howstr.bubbleapps.io/api/1.0/wf/get_img"
   --       end if
   --       put arrayfromjson(it) into tResponseA
   --       put tResponseA["response"]["image"] into tNewImage
   --       put tResponseA["response"]["filename"] into tNewImageName
   --       put base64decode(tNewImage) into url ("binfile:" & tNewFolder & "/" & tNewImageName)
   --       unlock screen
   --       wait 0 millisecs with messages
   --       --       get url tNewImageLink
   --       --       put      "http://s3.amazonaws.com/appforest_uf/f1496548544475x140387106221169240/grilled_cheese_on_plate.jpg" into theURL
   --       --       put url theURL into url ("binfile:" & tNewFolder & "/" & tNewImageName)
   --       -- put it into URL ("binfile:" & tNewFolder & "/" & tNewImageName)
   --       --       put URL tNewImageLink into URL ("binfile:" & tNewFolder & "/" & tNewImageName)
   --       --       put image tNewImageLink into URL ("binfile:" & tNewFolder & "/" & tNewImageName) -- error
   --       --       put URL ("binfile:" & tNewImageLink) into URL ("binfile:" & tNewFolder & "/" & tNewImageName) -- ! this isn't working
   --       -- it does create files, but they're corrupted
   --    end repeat
   
   put empty into field "liveForkField" stack "repowrangler" -- either it was downloaded or not found, either way erase label
   put empty into field "testForkField" stack "repowrangler" -- either it was downloaded or not found, either way erase label
   --    set itemdelimiter to "/"
   --    put tUnzipFold & "/" & tHowFileNewName & ".how" into tHowPath
   --    put URL ("binfile:" & tHowPath) into tHowData
   --    --    replace tOldID with tNewID in tHowData
   --    replace tReplaceMe with tHowFileNewName in tHowData
   --    put tHowData into URL ("binfile:" & tHowPath)
   --    repoWranglerLog("old project ID replaced with new ID in *.how file")
   return tNewFolder
end retrieveFork
--------------------------------------------------------- END GET FORK --------------------------------------------

on checkDownloads
   put cachedurls() into tUrls
   repeat for each line tUrl in tUrls
      put tUrl into tThisUrl
      put url tUrl into url "binfile:C:/Users/theyogi/Documents/howstr test projects"
      unload url tThisUrl
   end repeat
end checkDownloads
