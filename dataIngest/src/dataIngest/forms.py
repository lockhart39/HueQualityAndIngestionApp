# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
from django import forms
import datetime
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext as _

class dbLoginForm(forms.Form):
    selDB = forms.CharField(max_length=20)
    txtUsername = forms.CharField(max_length=50)
    txtPassword = forms.CharField(max_length=50)




class TableForm(forms.Form):
	srcdbase   = forms.ChoiceField(label='Source Database')
	srctable = forms.ChoiceField(label='Source Table')
	colbtn = forms.BooleanField(label='Custom Columns selection?', required=False)
	srccol = forms.MultipleChoiceField(label="Source Columns", required=False)
	#password = forms.CharField(label='Source Database Password', max_length=50, widget=forms.PasswordInput(render_value=False), required=False)
	#srcdbase = forms.CharField(label='Source Database Name', max_length=50, required=True, initial="")
	#srctable = forms.CharField(label='Source Table', max_length=50, required=True, initial="")
	#dstuser  = forms.CharField(label='Destination Database Username', max_length=50, required=False)
	#dstpass  = forms.CharField(label='Destination Database Password', max_length=50, widget=forms.PasswordInput(render_value=False), required=False)
	dstdbase = forms.ChoiceField(label='Destination Database')
	dsttable = forms.ChoiceField(label='Destination Table')
	clause   = forms.CharField(label='Where Clause', max_length=200, required=False)  
	datebtwn = forms.BooleanField(label='Ingest Range of Dates?', required=False)
	datename = forms.CharField(label='Date Column Name', required=False)
	startdate= forms.DateField(label='Start Date', required=False, initial=datetime.date.today)
	enddate  = forms.DateField(label='End Date', required=False, initial=datetime.date.today) 	

	def clean(self):
		cleaned_data = super(TableForm, self).clean()
		datebtwn = cleaned_data.get("datebtwn")
		colbtn= cleaned_data.get("colbtn")
		srccol= cleaned_data.get("srccol")
		datename = cleaned_data.get("datename")
		startdate= cleaned_data.get("startdate")
		enddate  = cleaned_data.get("enddate")
		srcdbase = cleaned_data.get("srcdbase")
		srctable = cleaned_data.get("srctable")
		dstdbase = cleaned_data.get("dstdbase")
		dsttable = cleaned_data.get("dsttable")
		#username = cleaned_data.get("username")
		#password = cleaned_data.get("password")
		#dstuser  = cleaned_data.get("dstuser")
		#dstpass  = cleaned_data.get("dstpass")
		ers = []
		#if username:
			#if not password:
				#ers.append(ValidationError(_('Please enter your source database password.'), code='pw_error'))
		#if dstuser:
			#if not dstpass:
				#ers.append(ValidationError(_('Please enter your destination database password.'), code='dstpw_error'))
		if not srcdbase or not srctable or srctable == "None":
			ers.append(ValidationError(_('Please enter your source database and source table.'), code='src_error'))
		if not dstdbase or not dsttable or dsttable == "None":
			ers.append(ValidationError(_('Please enter your destination database and destination table.'), code='dst_error'))
		if datebtwn:
			if not datename:
				ers.append(ValidationError(_('Please enter the column name for date selection.'), code='datename_error'))
			if not startdate and not enddate:
				ers.append(ValidationError(_('Please enter at least one date (YYYY-MM-DD).'), code='date_error'))
			if startdate:
				if str(enddate) < str(startdate):
					ers.append(ValidationError(_('Please enter an end date later than the start date.'), code='date_order'))
				
		if ers:
			raise ValidationError(ers)

			
		return self.cleaned_data
