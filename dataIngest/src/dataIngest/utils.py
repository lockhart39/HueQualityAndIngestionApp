import subprocess
import os
from django.http import HttpResponse
import json
import re
import fnmatch

def sqoopTable(db, srcDB, username, password, srcTable, srcColumns, stgDB, stgTable, splitBy):
    try:
        connector = ""
        if db == "mysql": connector = "jdbc:mysql://localhost:3306/"
        elif db == "postgres": connector = "jdbc:postgresql://localhost:5432/"
        else: return False
        os.system("sqoop import --connect " + connector + srcDB + \
                " --username " + username + \
                " --password " + password + \
                " --table " + srcTable + \
                " --delete-target-dir" + \
                " --split-by " + splitBy + \
                " --hive-drop-import-delims" + \
                " --columns " + ",".join(srcColumns) + \
                " --hive-import --hive-overwrite --hive-table " + stgDB + "." + stgTable) 
        result = subprocess.Popen(["if hdfs dfs -test -e '/user/hive/warehouse/" + stgDB + ".db/" + stgTable + "'; then echo 'True'; fi"], shell=True, stdout=subprocess.PIPE).communicate()[0]
        os.system("rm *.java")
        return result == "True\n"
    except:
        return False

def dbLogin(db, username, password):
    if db == "mysql":
        try:
            output = subprocess.Popen(["mysql", "-u" + username, "-p" + password, "--execute=SELECT USER()"], stdout=subprocess.PIPE).communicate()[0]
            return output[0:6] == "USER()"
        except:
            return False
    elif db == "postgres":
        try:
            my_env = os.environ.copy()
            my_env["PGPASSWORD"] = password
            output = subprocess.Popen(["psql", "-w", "-U" + username, "-c", " "], stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=my_env).communicate()
            return not any("FATAL:" in s for s in output) and not any("unknown user:" in s for s in output)
        except:
            return False
    else:
        return False
    
def getDatabaseNames(db, username, password):
    if db == "mysql":
        try:
            dbNames = subprocess.Popen(["mysql",  "-u" + username, "-p" + password, "--execute=SHOW DATABASES", "-N"], stdout=subprocess.PIPE).communicate()[0]
            dbList = []
            for d in dbNames.split():
                dbList.append(d)
            return dbList
        except:
            return []
    elif db == "postgres":
        try:
            my_env = os.environ.copy()
            my_env["PGPASSWORD"] = password
            dbNames = subprocess.Popen(["psql", "-w", "-U" + username, "-t", "-A", "-c", "select datname from pg_database"], stdout=subprocess.PIPE, env=my_env).communicate()[0]
            dbList = []
            for d in dbNames.split():
                dbList.append(d)
            return dbList
        except:
            return []
    else:
        return []

def getTables(request):
    db = request.GET.get('db', False)
    dbName = request.GET.get('dbName', False)
    u = request.GET.get('u', False)
    p = request.GET.get('p', False)
    if db == "mysql":
        tables = subprocess.Popen(["mysql",  "-u" + u, "-p" + p, "--database=" + dbName, "--execute=SHOW TABLES", "-N"], stdout=subprocess.PIPE).communicate()[0].split()
    elif db == "postgres":
        my_env = os.environ.copy()
        my_env["PGPASSWORD"] = p
        tables = subprocess.Popen(["psql", "-w", "-U" + u, "-t", "-A", "-c", "SELECT table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema')", dbName], stdout=subprocess.PIPE, env=my_env).communicate()[0].split()
    return HttpResponse(json.dumps(tables), content_type="application/json")

def getColumns(request):
    db = request.GET.get('db', False)
    dbName = request.GET.get('dbName', False)
    u = request.GET.get('u', False)
    p = request.GET.get('p', False)
    table = request.GET.get('t', False)
    if db == "mysql":
        columns = subprocess.Popen(["mysql",  "-u" + u, "-p" + p, "--database=" + dbName, "--execute=SELECT COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = database() AND TABLE_NAME = '" + table + "'", "-N"], stdout=subprocess.PIPE).communicate()[0].split()
    elif db == "postgres":
        my_env = os.environ.copy()
        my_env["PGPASSWORD"] = p
        dirtyColumns = subprocess.Popen(["psql", "-w", "-U" + u, "-t", "-A", "-c", "\d+ %s" % table, dbName], stdout=subprocess.PIPE, env=my_env).communicate()[0].split('\n')
        columns = []
        for column in dirtyColumns:
            cleanColumn = column.split('|')[0]
            print cleanColumn
            if not cleanColumn.isspace() and cleanColumn != None and cleanColumn != "":
                columns.append(cleanColumn)
        print columns
    return HttpResponse(json.dumps(columns), content_type="application/json")


def getHiveDatabaseNames():
    try:
        dbNames = subprocess.Popen(["beeline", "--showHeader=false", "--outputformat=dsv", "--delimiterForDSV=newline", "-u", "jdbc:hive2://localhost:10000/", "-e", "show databases;"], stdout=subprocess.PIPE).communicate()[0].split()
        return dbNames
    except:
        return []


def ajaxHiveDatabaseNames(request):
    dbNames = subprocess.Popen(["beeline", "--showHeader=false", "--outputformat=dsv", "--delimiterForDSV=newline", "-u", "jdbc:hive2://localhost:10000/", "-e", "show databases;"], stdout=subprocess.PIPE).communicate()[0].split()
    return HttpResponse(json.dumps(dbNames), content_type="application/json")


def getHiveTables(request):
    db = request.GET.get('db', False)
    tables = subprocess.Popen(["beeline", "--showHeader=false", "--outputformat=dsv", "--delimiterForDSV=newline", "-u", "jdbc:hive2://localhost:10000/", "-e", "use " + db + "; show tables;"], stdout=subprocess.PIPE).communicate()[0].split()
    return HttpResponse(json.dumps(tables), content_type="application/json")


def getCSVContext(dbexists, texists, isHeader, delimiter, filepath, metaCSV, request):
    columnNums = ''
    columnNames = []
    columnTypes = []
    columnInfo = ''
    context = {}
    print "isHeader is equal to "
    print isHeader

# FOR THE TIME BEING WE ARE NOT GIVING USERS THE ABILITY TO CREATE DATABASES
# ----------------------------------------------------------------------------------------------------
# FIRST CASE:
#               NEITHER A DATABASE OR A TABLE ALREADY EXIST SO THEY
#               MUST BE CREATED IN HIVE BEFORE THE CSV IS PUSHED
#               INTO HDFS
#
#               Currently gone so users can't create databases all willy nilly
# END FIRST CASE
# ----------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------
# SECOND CASE:
#               A DATABASE ALREADY EXISTS IN HIVE BUT THE TABLE DOES NOT.
#               A TABLE MUST BE CREATED FROM USER INPUT BEFORE THE CSV
#               CAN BE PLACED INTO HDFS

    if texists == 'No':
        db = request.POST.get('selDB')
        table = request.POST.get("table2")
        db = db.lower()
        table = table.lower()
        columnNums = request.POST.get("colAmt")

        if isHeader == "Yes":
            header = []
            meta = []
            with open(filepath, 'rb+') as csv:
                line = csv.readline().strip()
                data = csv.read().splitlines(True)
            with open(filepath, 'wb+') as csv:
                csv.writelines(data[1:])
            line = line.replace(delimiter, ' ')
            for word in line.split():
                header.append(word)
            if metaCSV == 'yes':
                csvpath = os.path.dirname(os.path.abspath(__file__))
                csvpath = csvpath + '/meta.csv'
                with open(csvpath, 'rb+') as csv:
                    metadata = csv.read().splitlines()
                print metadata  # test
                for item in metadata:
                    tmp = item.split(',')
                    print tmp  # test
                    if tmp[1] == "varchar":
                        tmp[1] = tmp[1] + "(" + tmp[2] + ")"
                    meta.append(tmp[0])
                    meta.append(tmp[1])
                meta = dict(zip(meta[0::2], meta[1::2]))
                print meta  # test
                ordered_meta = [(col, meta[col]) for col in header]
                print ordered_meta  # test

                for tup in ordered_meta:
                    print tup  # test
                    columnNames.append(tup[0])
                    columnTypes.append(tup[1])
                    columnInfo = columnInfo + tup[0] + " with field of type " + tup[1] + "\n"
            else:
                for word in line.split():
                    columnNames.append(word)
                    columnTypes.append('string')
                    columnInfo = columnInfo + str(columnNames[-1]) + "\n"
        elif metaCSV == 'yes' and isHeader == "No":
            csvpath = os.path.dirname(os.path.abspath(__file__))
            csvpath = csvpath + '/meta.csv'
            with open(csvpath, 'rb+') as csv:
                ml = csv.read().splitlines()
                print ml
            for data in ml:
                tmp = data.split(',')
                columnNames.append(tmp[0])
                if tmp[1] == 'varchar':
                    columnTypes.append(tmp[1] + '(' + tmp[2] + ')')
                else:
                    columnTypes.append(tmp[1])
                columnInfo = columnInfo + str(columnNames[-1]) + " with field of type " + str(columnTypes[-1]) + "\n"
        else:
            # for loop wasnt doing what I wanted so I used a while with an index instead. Seems to work, please don't touch.
            i = 0
            while i < len(columnNums):
                if columnNums[i] != ',':  # the numbers of each column name come in a string. Each number seperated by a comma
                    tmp = columnNums[i]
                    if i != (len(columnNums) - 1) and columnNums[i + 1] != ',':  # This if is for when the column number has more than 1 digit
                        tmp = tmp + columnNums[i + 1]
                        i = i + 1  # extra increment since we're grabbing more than one char in the string
                    columnNames.append(request.POST.get("Column Name " + tmp))
                    columnTypes.append(request.POST.get("coltype" + tmp))
                    columnInfo = columnInfo + str(columnNames[-1]) + " with field of type " + str(columnTypes[-1]) + "\n"
                i = i + 1  # increment index
            # end while

        tbl_create = ("use " + db + ";\n" +
                      "create table " + table + "(\n")
        for i in range(len(columnNames)):
            # the if statement gets rid of the comma and newline after the last column definition
            if(i == len(columnNames) - 1):
                tbl_create = tbl_create + columnNames[i] + " " + columnTypes[i]
            else:
                tbl_create = tbl_create + columnNames[i] + " " + columnTypes[i] + ",\n"
        tbl_create = tbl_create + ')\nROW FORMAT DELIMITED FIELDS TERMINATED BY "' + delimiter + '" stored as textfile;'

        #   print tbl_create  # test

        make_table = ("beeline -u jdbc:hive2://localhost:10000 -e '" + tbl_create + "'")
        print make_table
        p = subprocess.Popen(make_table, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[0]
        print p

        put_cmd = 'hdfs dfs -put ' + filepath + ' /user/hive/warehouse/' + db + '.db/' + table
        p = subprocess.Popen(put_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[0]
        print p
        texists = ''
        context = {'db': db,
                   'table': table,
                   'delimiter': delimiter,
                   'dbexists': dbexists,
                   'texists': texists,
                   'columnNums': columnNums,
                   'colInfo': columnInfo,
                   'colTypes': columnTypes}
# END SECOND CASE
# ----------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------
# FINAL CASE:
#               THE DATABASE AND THE TABLE ALREADY EXIST IN HIVE
#               THE CSV JUST NEEDS TO BE PLACED IN THE CORRECT LOCATION
#               IN HDFS

    else:
        # The easy one! Just puts the csv into hive via Popen functions
        db = request.POST.get('selDB')
        table = request.POST.get("selTable")
        db = db.lower()
        table = table.lower()
        if isHeader == 'Yes':
            with open(filepath, 'rb+') as csv:
                data = csv.read().splitlines(True)
            with open(filepath, 'wb+') as csv:
                csv.writelines(data[1:])
        print "DB and table both exist."
        context = {'db': db,
                   'table': table,
                   'delimiter': delimiter,
                   'dbexists': dbexists,
                   'texists': texists,
                   'columnNums': columnNums,
                   'colInfo': columnInfo,
                   'colTypes': columnTypes}
        # p = subprocess.Popen('pwd', stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[0]
        # path = p[:-1] + '/dataIngest/src/dataIngest/tmp.csv'

        put_cmd = 'hdfs dfs -put ' + filepath + ' /user/hive/warehouse/' + db + '.db/' + table
        p = subprocess.Popen(put_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[0]
        print p
# END FINAL CASE
# ----------------------------------------------------------------------------------------------------
    return context
# END GETCSVCONTEXT
# ----------------------------------------------------------------------------------------------------


def exportToCSV(db, table, columns, fileName, filePath, delimiter):
    cmd = "ls " + filePath
    if fileName[-4:] == '.csv' or fileName[-4:] == '.txt':
        pass
    else:
        fileName = fileName + '.csv'
    if filePath[-1] == '/':
        localPath = filePath + fileName
    else:
        localPath = filePath + '/' + fileName
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[1]
    print p
    if p != '':
        context = {'dbNames' : getHiveDatabaseNames(),
                   'noPath' : 'Yes',
                   'exSuccess' : '',
                   'exFail' : ''
                   }
        return context
    else:
        # get local path to data directory in dataIngest app
        hdfsPath = '/user/cloudera/export/'
        # print columns
        # set up command to insert hive table into local directory as a flat file
        export_cmd = "insert overwrite directory '" + hdfsPath + "' row format delimited fields terminated by '" + delimiter + "' select " + ",".join(columns) + " from " + db + "." + table + ";"
        bline = 'beeline -u jdbc:hive2://localhost:10000 -e "' + export_cmd + '"'
        # print bline
        p = subprocess.Popen(bline, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[1]
        print p
        hdfsPath += '/000000_0'
        tmpPath = os.path.dirname(os.path.abspath(__file__))
        tmpPath += '/data'
        copy_cmd = 'hdfs dfs -get ' + hdfsPath + ' ' + tmpPath
        p = subprocess.Popen(copy_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[1]
        print p
        tmpPath += '/000000_0'
        with open(tmpPath, 'r') as source:
            data = source.read().splitlines(True)
        with open(localPath, 'wb+') as dest:
            dest.writelines(data)
        # remove 000000_0 from temp data directory otherwise it doesn't overwrite
        rm_cmd = "rm " + tmpPath
        p = subprocess.Popen(rm_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[1]
        print p

        # Check to see if new flat file was correctly put in correct location
        success = False
        for file in os.listdir(filePath):
            if fnmatch.fnmatch(file, fileName):
                success = True
        if success is True:
            context = {'dbNames' : getHiveDatabaseNames(),
                       'noPath' : '',
                       'exSuccess' : 'Yes',
                       'exFail' : ''
                       }
            return context
        else:
            context = {'dbNames' : getHiveDatabaseNames(),
                       'noPath' : '',
                       'exSuccess' : '',
                       'exFail' : 'Yes'
                       }
            return context


# Hive to hive Ajax functions
def getDatabasesHive(request):
    #username = request.GET.get('u', False)
    #dbs = check_output(["mysql",  "-u" + username, "-p" + pswd, "--execute=SHOW DATABASES", "-N"]).split('\n')
    dbs=subprocess.Popen("beeline --showHeader=false --outputFormat=tsv2 -u jdbc:hive2://localhost:10000 -e \'SHOW DATABASES\'", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0].split()
    return HttpResponse(json.dumps(dbs), content_type="application/json")

def getTablesHive(request):
    database = request.GET.get('db', False)
    tbls=subprocess.Popen("beeline --showHeader=false --outputFormat=tsv2 -u jdbc:hive2://localhost:10000 -e \'SHOW TABLES FROM "+ database+"\'", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0].split()
    return HttpResponse(json.dumps(tbls), content_type="application/json") 
    
def getColHive(request):
    db = request.GET.get('db', False)
    table = request.GET.get('t', False)
    columns=subprocess.Popen("beeline --showHeader=false --outputFormat=tsv2 -u jdbc:hive2://localhost:10000 -e \'SHOW COLUMNS FROM "+ db+"."+table+"\'", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0].split()
    return HttpResponse(json.dumps(columns), content_type="application/json")

def getSample(request):
    q = request.GET.get('query', False)
    query = q[q.lower().find("select"):].replace("\n"," ").replace("\r"," ").replace("/r"," ").replace("\'","\"")
    if query.find(";") >= 0:
        query=query[:-1]
    result = subprocess.Popen("beeline --showHeader=true --outputFormat=csv2 -u jdbc:hive2://localhost:10000 -e \'"+query+" limit 50;\'",shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0]
    result = result.replace(",", ", ")
    n = result.find(".")
    table = result[0:n+1]
    result=result.replace(table,"")
  
    if result == "":
        result = "Query returned error or no data, please check your syntax."
    return HttpResponse(json.dumps(result), content_type="application/json")



# creates query string for Hive to Hive
def query_string(context):
	dt = context['datebtwn']						# DaTe, hence dt
	for i in context:
		context[i] = str(context[i]).strip() 				# Removes extra spaces at beginning and end of text
		context[i] = re.sub("\s\s+", " ", context[i]) 			# Removes extra spaces in the text		
	dst = context['dstdbase'] + "." + context['dsttable']			#
	src = context['srcdbase'] + "." + context['srctable']			# so i don't have to write this out every time
	srcd = src + "."							# src and a dot, hence srcd
	tbld = context['srctable'] + "." 					# table and a dot, hence tbld
	cls = context['clause']							# CLauSe, hence cls
	if context['startdate'] == "None":
		ds = ""								# Date Start, hence ds
	else:
		ds = '\'' + str(context['startdate']) + '\''
	if context['enddate'] == "None":	
		de = ""								# Date End, hence de
	else:
		de = '\'' + str(context['enddate']) + '\''			# assigning variables so don't need to type out
	k = True								# Variable to see if "WHERE " needs to be appended before date stuff	
	msg = "INSERT INTO " + dst
#kyle addition, checks if columns exist, if so adds to string
	colck = context['colbtn']
	columns = context['srccol']
	col =""
	for c in columns.split():
		col = col + c
	col =col.replace('[',"").replace(']',"").replace("u\'","").replace("\'","")
	if colck == "True":
		if col:
			msg=msg+"\nSELECT "+col+"\nFROM "+src
		else:
			msg = msg + "\nSELECT * FROM " + src
	else: 									# INSERT INTO destination_database.destination_table
		msg = msg + "\nSELECT * FROM " + src 				# SELECT * FROM source_database.source_table
#end of kyle addition
	if cls: 								# checks if there's a where statement, not including a date between
		if re.search('where', cls[:8].lower()): 			# checks if user used "where" in their statement
			msg = msg + " " + "\nWHERE " 
			st = 6 							# skips "where " from where clause
			if not re.finditer("and", cls.lower()): 		# searches where clause for "and"s
				msg = msg + tbld + cls[6:] 			# if none found, assume word after "where " is column name, append source_tb. before it
			else:													
				for m in re.finditer("and", cls.lower()): 	# if any "and"s found, appends source_tb. to 
					msg = msg + tbld + cls[st:m.end()+1] 	# the word immediately following them, which is assumed to
					st = m.end()+1                       	# be a column name
					
			k = False						# "WHERE " already found/included, don't need to add to date stuff
			msg = msg + tbld + cls[st:]
		else:								# Same as above, just if "where" wasn't found.
			msg = msg + "\nWHERE "					# Could probably combine the two, don't want to break though
			st = 0
			if not re.finditer("and", cls.lower()):
				msg = msg + tbld + cls
			else:
				for m in re.finditer("and", cls.lower()):
					msg = msg + tbld + cls[st:m.end()+1]
					st = m.end()+1
			k = False
			msg = msg + tbld + cls[st:]

	if dt:									# If the user checked the date box
		if k:								# If a where statement wasn't found
			msg = msg + "\nWHERE " + tbld + context['datename'] 	#+ " BETWEEN "
		else:
			msg = msg + " \nAND " + tbld + context['datename'] 	#+ " BETWEEN "
		
		if not de:
			msg = msg + " >= " + ds;
		elif not ds:
			msg = msg + " <= " + de;
		else:
			msg = msg + " BETWEEN " + ds + " AND " + de		# Adds the two dates to the string, with ''s around the dates

	msg = msg + ";"
	while re.search(tbld+tbld, msg):					# Replaces instances of multiple database/table identifiers,
		msg = msg.replace(tbld + tbld, tbld)				# eg. src_db.src_tb.src_db.src_tb.customers would turn into
										# src_db.src_tb.customers -- just incase user adds them 
	while re.search(tbld+srcd, msg):
		msg = msg.replace(tbld+srcd, tbld)		
	msg = msg.replace("\"", "\'")						# Replaces any instance of double quotes being used with single quotes
	return msg


#SQL ajax auto populate functions
def getDatabasesSql(request):
	p = request.GET.get('p', False)
	u = request.GET.get('u', False)
	dbs=subprocess.Popen("mysql -u "+u+" --password="+p+" --execute=\'Show databases;\' -N", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0].split()
	return HttpResponse(json.dumps(dbs), content_type="application/json")

def getTablesSql(request):
	p = request.GET.get('p', False)
	u = request.GET.get('u', False)
	db= request.GET.get('db', False)
	tbls=subprocess.Popen("mysql -u "+u+" --password="+p+" --execute=\'use "+db+"; show tables;\' -N", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0].split()
	return HttpResponse(json.dumps(tbls), content_type="application/json")



