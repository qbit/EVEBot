#!/usr/bin/ruby

require 'rubygems'
require 'ruby-debug'

require 'growl'
require 'net/http'
require 'xmlsimple'
require 'twitter'

USERID = ''
APIKEY = ''
CHARACTERID = ''

raise 'Need UserID CharacterID and API Key to continue!' \
    if (not USERID) or (not APIKEY) or (not CHARACTERID)


def getImage(charId)
    ava_url = "http://img.eve.is/serv.asp?s=256&c="+charId
    ava_url = OSX::NSURL.alloc.initWithString(ava_url)
    i = OSX::NSImage.alloc.initWithContentsOfURL(ava_url)
    return i
end

def getcharXml
    skillurl = "http://api.eve-online.com"+
    "/char/SkillInTraining.xml.aspx"+
    "?userID="+USERID+
    "&apiKey="+APIKEY+
    "&characterID="+CHARACTERID 

    training_data = Net::HTTP.get_response(URI.parse(skillurl)).body 

    char_data = XmlSimple.xml_in(training_data)

    return char_data
end

def getskillXml(skillId)
    if (!File.exist?("SkillTree.xml")) 
        puts "Getting SkillTree"
        skillData = Net::HTTP.get_response(URI.parse("http://api.eve-online.com/eve/SkillTree.xml.aspx")).body
        skill_data = XmlSimple
        #skill_data.xml_in(skillData)
        File.open("SkillTree.xml", "w" ) { |f|
            f << skill_data.xml_out(skillData) 
        }
    else 
        skill_data = XmlSimple.xml_in("SkillTree.xml")
    end

end

def notify(type, title, msg, icon)
    types = Array[ 'eve_notify', 'issue']
    g = Growl::Notifier.sharedInstance
    g.register( 'eve-growl', types)
    g.notify( type, title, msg, :icon => icon)
end

icon = getImage(CHARACTERID)

training = getcharXml
skill_ref = getskillXml('3232')
time = training['currentTime'].to_s
currentSkill = training['result'][0]['trainingTypeID'][0]


twit = Twitter::Base.new('twitterusername', 'twitterpassword').update('training ' + currentSkill );
