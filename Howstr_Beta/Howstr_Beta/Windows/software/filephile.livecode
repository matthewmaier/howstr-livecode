script "filephile"
on devLog pPhase
   --   -- ! commented out 15DEC2015 cuz logging slows things down a lot
   --   -- pPhase[write]=append to development log file
   --   put pPhase["write"] into tWrite
   --   set the itemDelimiter to "/"
   --   get the effective fileName of this stack
   --   set the defaultFolder to item 1 to -2 of it
   --   put the defaultFolder into tFolder
   --   --   replace "software" with "logs" in tFolder
   --   -- ! apparently "this stack" is returning the main stack, not the folder filephile is in
   --   put URL ("file:" & tFolder & "/logs/development.txt") into tLog
   --   if tWrite is "initiate" then
   --      --      put empty into tLog
   --      put the long time into tLog
   --   else
   --      put tWrite into line (the number of lines of tLog)+1 of tLog
   --   end if
   --   put tLog into URL ("file:" & tFolder & "/logs/development.txt")
end devLog

command userOpen pFile -- bypassed for what's in loadButtMouseUp
   put "command userOpen" into xX["write"];    devLog xX
   -- pFile is the filepath of the document to open
   put URL ("file:" & pFile) into tJason
   --   put arrayFromJson(tArray) into sMain[sNowDoc]
   --   dispatch "myCommand" to card "myCard" with "Hello World", tArray, tCSV
   dispatch "cmdArrayFromJson" to stack "easyJSON" with tJason
   put the result into sMain[sNowDoc]
   render
end userOpen

command userSave pFile
   put "command userSave" into xX["write"];    devLog xX
   -- pFile is the filepath of the document to save (or save over)
   put sMain[sNowDoc] into tArray
   --   put the keys of tArray into tKeys
   --   sort tKeys numeric ascending
   --   repeat for each line tRec in tKeys
   --   end repeat
   --   put jsonFromArray(tArray) into URL ("file:" & pFile)
   dispatch "cmdJsonFromArray" to stack "easyJSON" with tArray
   put the result into URL ("file:" & pFile)
end userSave

command userClose
   put "command userClose" into xX["write"];    devLog xX
   -- delete graphic objects
   put the keys of sGraphics[sNowDoc] into tKeys
   repeat for each line tRec in tKeys
      if exists(sGraphics[sNowDoc][tRec]["longID"]) then
         -- delete the node graphic
         delete sGraphics[sNowDoc][tRec]["longID"]
      end if
   end repeat
   
   put empty into sMain[sNowDoc]
   put empty into sGraphics[sNowDoc]
   put empty into sExpanded
   put empty into sNowItem
   put empty into sThenItem
   --   put "New" into field "savedField" stack "primary"
   --   put empty into field "filepathField" stack "primary"
   -- sNowDoc won't change from 1
   
   -- ! this is first done in the preOpenStack handler
   put "step myStep turn myTurn bond prev next skim read bulk trim" \
         into sPointerTags
   put empty into sMain
   put 1 into sNowDoc
   put true into sMain[sNowDoc][0]["hide"]
   put 0 into sMain[sNowDoc][0][lastKey]
   put empty into sNowItem
   
   put "2,1" & cr & "3,1" & cr & "4,1" into sMain[sNowDoc][1]["step"]
   put "state" into sMain[sNowDoc][2]["type"]
   put "1,1" into sMain[sNowDoc][2]["myStep"]
   put "untitled project" into sMain[sNowDoc][3]["title"]
   put "1,1" into sMain[sNowDoc][3]["myStep"]
   put "500,10" into sMain[sNowDoc][4]["coord"]
   put "1,1" into sMain[sNowDoc][4]["myStep"]
   put 4 into sMain[sNowDoc][0][lastKey]
   
   -- erase any leftover graphics ------------------------------------------
   -- this will erase everything in the group except floorRect
   --   put 0 into tControl
   --   repeat for the number of controls of group "graphicNetwork" of stack "primary"
   --      add one to tControl
   --      put the name of control tControl of group "graphicNetwork" of stack "primary" & cr after tList
   --   end repeat
   --   repeat for each line tLine in tList
   --      if "id" is among the words of tLine then delete tLine
   --   end repeat
   
   -- ! close one of multiple open docs
   render
end userClose

function correctAbsoluteMediaPath pPaths
   -- accepts the absolute path the *.how file was loaded from this time
   -- and assumes it's in a project folder with any associated media
   -- and assumes the *.how file has the same name as the project folder
   -- and also accepts whatever path is available to try to get to the media
   -- that could be just a filename, or an absolute path, or an out-of-date absolute path, URL, etc
   -- pPaths[projectFile] = absolute path to the *.how file currently open
   -- pPaths[targetMedia] = some kind of path to the desired media
   -- after 3MAR2016 tags with URIs are relative; before then they were absolute (stupid, I know)
   -- the important part is the folder; if it matches we can adjust the path; if not it must be external
   -- ! techncially this could be a problem since two different could use the same project folder name
   set itemdelimiter to slash
   put "Error: no paths provided" into tForReturn
   -- since the *.how file is supposed to be in the same folder as the media...
   -- this should work for absolute & relative media paths
   put pPaths["projectFile"] into tForReturn
   put item -1 of pPaths["targetMedia"] into item -1 of tForReturn
   -- it's possible the media path is external, like a URL
   -- if so then it's the user's problem if the path doesn't work
   put item -2 of pPaths["projectFile"] into tProjectFolder -- currently open *.how file's folder
   put item -2 of pPaths["targetMedia"] into tMediaFolder
   if tMediaFolder is not empty and tMediaFolder is not tProjectFolder then put pPaths["targetMedia"] into tForReturn
   return tForReturn
end correctAbsoluteMediaPath

function saveNewProject pPaths
   -- pPaths["newPath"] = full path, no filename
   set itemdelimiter to slash
   create folder pPaths["newPath"]
   put item -1 of pPaths["newPath"] into tFilename
   put pPaths["newPath"] & "/" & tFileName & ".how" into tFullName
   put pPaths["fileData"] into URL ("file:" & tFullName)
   return tFullName
   --   put "saved" into sMain[sNowDoc][0]["saveStatus"]
   --   put tFullName into sMain[sNowDoc][0]["filepath"]
   --   put item -1 of tFullName into tForShow
   --   replace ".how" with "" in tForShow
   --   put tForShow into field "filenameLabel" stack "HowstrBeta"
end saveNewProject

function loadNewProject pPaths
   -- pPaths["newProjectFolder"] = path to the folder containing the project
   put "Error in loadNewProject: some-project.how not found" into tForReturn["data"]
   put pPaths["newProjectFolder"] into tFullPath
   set itemdelimiter to slash
   put "/" & item -1 of tFullPath & ".how" after tFullPath
   if there is a file tFullPath then
      put URL ("file:" & tFullPath) into tForReturn["data"]
      put tFullPath into tForReturn["fullPath"]
   end if
   return tForReturn
end loadNewProject
