require 'viewpoint'
require 'mongo'
require 'fileutils'
require 'base64'

include Viewpoint::EWS
include Mongo

$attachments_absolute_dir = File.join Dir.pwd, 'attachments'
# initialize viewpoint
def init_viewpoint
	endpoint = 'https://mail.cisco.com/ews/Exchange.asmx'
	user = 'username'
	pass = 'password'
	cli = Viewpoint::EWSClient.new endpoint, user, pass
end

def init_db
	# init mongo db
	client = MongoClient.new
	db = client['feedback']
	return db
end

# find specific folder
def find_prt_folder(ews)
	prt_folder = ews.get_folder_by_name 'PRT', root: :root, traversal: :deep
end

# download unread mails
def download_unread_mails(ews,db)
	puts 'Start to reading mails...'
	prt_folder = find_prt_folder(ews)
	items = prt_folder.unread_messages
	for item in items
		attachments = save_attachments item
		save_to_db db, item, attachments
		item.mark_read!
	end
	# puts "I am going to sleep 2 minutes!"
	sleep 2 * 60
end

# save all the attachments of a mail
def save_attachments(mail)
	attachments = []
	atts = mail.attachments || []
	for att in atts
		is_file = att.instance_of?(Viewpoint::EWS::Types::FileAttachment)
		save_to_file att if is_file
		attachments << {
			:is_file			=>	is_file,
			:content_id			=>  att.content_id,
			:file_name			=>	is_file ? att.file_name : nil,
			:content_type 		=>	att.content_type,
			:size				=> 	att.size,
			:parent_change_key	=> 	att.parent_change_key,
			:parent_item_id		=>	att.parent_item_id,
			:is_inline			=>  att.is_inline?,
			:is_contact_photo	=>	is_file ? att.is_contact_photo? : false
		}
	end
	return attachments
end


# ItemAttachment: EWS METHODS: content_id, content_type, id, is_inline?, last_modified_time, name, parent_change_key, parent_item_id, size
# <t:Attachments>
#   <t:ItemAttachment>
#     <t:AttachmentId Id="AAMkAGE3MWNiNTI4LTIyMDgtNDVjZi1hNWFhLTZjOTY1OWM5M2ZhYgBGAAAAAAD15bW3O4mzQK5XbIe6KPMBBwDNE7q4DwGtQraGpizKJoFRAAAAjS+bAADNE7q4DwGtQraGpizKJoFRAAAAj++8AAABEgAQAAeUrxKxwH5NuUwDqbHJLLE="/>
#     <t:Name>Re: [SM-P900]Problem Report: Cisco Jabber for Android 9.6.0.170226: 2014-03-14 00:05:15</t:Name>
#     <t:ContentType>message/rfc822</t:ContentType>
#     <t:ContentId>DBF7B33DD06B3F40A4BB2ED79989A335@emea.cisco.com</t:ContentId>
#     <t:Size>3003</t:Size>
#     <t:LastModifiedTime>2014-03-14T04:53:45</t:LastModifiedTime>
#     <t:IsInline>false</t:IsInline>
#   </t:ItemAttachment>
# </t:Attachments>

# FileAttachment: EWS METHODS: content, content_id, content_type, file_name, id, is_contact_photo?, is_inline?, last_modified_time, name, parent_change_key, parent_item_id, size
# <t:Attachments>
#   <t:FileAttachment>
#     <t:AttachmentId Id="AAMkAGE3MWNiNTI4LTIyMDgtNDVjZi1hNWFhLTZjOTY1OWM5M2ZhYgBGAAAAAAD15bW3O4mzQK5XbIe6KPMBBwDNE7q4DwGtQraGpizKJoFRAAAAjS+bAADNE7q4DwGtQraGpizKJoFRAAAAj/BGAAABEgAQAHX0LfGdwiNPmDQMLjYAN9s="/>
#     <t:Name>Jabber-Android-2014-03-20 18h08m-LOGS.zip</t:Name>
#     <t:ContentType>application/zip</t:ContentType>
#     <t:ContentId>8812322829426D4AA0C12CA42249807A@emea.cisco.com</t:ContentId>
#     <t:Size>4686759</t:Size>
#     <t:LastModifiedTime>2014-03-20T10:27:14</t:LastModifiedTime>
#     <t:IsInline>false</t:IsInline>
#     <t:IsContactPhoto>false</t:IsContactPhoto>
#   </t:FileAttachment>
# </t:Attachments>


# write attachment file to disk
def save_to_file(attachment)
	puts attachment
	filePath = File.join get_file_path(Time.new.strftime('%Y%m%d')), attachment.name
	File.open(filePath, "w+") do |f|
		f.write Base64.decode64(attachment.content)
	end
end

def get_file_path(relative_path)
  	path =  File.join $attachments_absolute_dir, relative_path
  	unless File.directory?(path)
        FileUtils.mkdir_p path
  	end
  	return path
end

# write mail info to db
# associated?, attachments, body, body_type, categories, cc_recipients,
# change_key, conversation_id, conversation_index, conversation_topic,
# date_time_created, date_time_sent, draft?, extended_properties, from,
# has_attachments?, id, importance, internet_message_headers,
# internet_message_id, is_associated?, is_draft?, is_read?,
# is_submitted?, item_id, mime_content, read?,
# sender, sensitivity, size, subject, submitted?, to_recipients
def save_to_db(db, mail, attachments)
	coll = db.collection 'prts'
	puts "save_to_db to print mail object"
	prt = {
		:email_id 				=> mail.id,
		:sender 				=> {
			:name 				=> mail.sender.name,
			:email 				=> mail.sender.email
		},
		:subject				=> mail.subject,
		:conversation_id 		=> mail.conversation_id,
		:conversation_index 	=> mail.conversation_index,
		:conversation_topic  	=> mail.conversation_topic,
		:body 					=> mail.body,
		:body_type 				=> mail.body_type,
		:categories 			=> mail.categories,
		:change_key				=> mail.change_key,
		:to_recipients 			=> convert_to_recipients(mail),
		:attachments 			=> attachments
	}
	coll.insert prt
end

def convert_to_recipients(mail)
	to_recipients = [];
	for user in mail.to_recipients
		recipient = {
			:name 	=> user.name,
			:email 	=> user.email
		}
		to_recipients << recipient
	end
	return to_recipients
end


def main
	ews = init_viewpoint
	db = init_db
	download_unread_mails ews, db
end


main
