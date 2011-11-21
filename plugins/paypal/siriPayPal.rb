require 'tweakSiri'
require 'siriObjectGenerator'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "text siri proxy" and responds
# with a message about the proxy being up and running. This is good base code for other plugins.
# 
# Remember to add other plugins to the "start.rb" file if you create them!
######

class SiriPayPal < SiriPlugin
  def initialize
    @state = :DEFAULT
  end
  
  def generate_msg_response(refId, text="")
    object = SiriAddViews.new
		object.make_root(refId)

		answer = SiriAnswer.new("PayPal", [
			SiriAnswerLine.new('logo','http://cl.ly/1l040J1A392n0M1n1g35/content'), # this just makes things looks nice, but is obviously specific to my username
			SiriAnswerLine.new(text)
		])
		confirmationOptions = SiriConfirmationOptions.new(
			[SiriSendCommands.new([SiriConfirmSnippetCommand.new(),SiriStartRequest.new("yes",false,true)])],
			[SiriSendCommands.new([SiriCancelSnippetCommand.new(),SiriStartRequest.new("no",false,true)])],
			[SiriSendCommands.new([SiriCancelSnippetCommand.new(),SiriStartRequest.new("no",false,true)])],
			[SiriSendCommands.new([SiriConfirmSnippetCommand.new(),SiriStartRequest.new("yes",false,true)])]
		)

		object.views << SiriAssistantUtteranceView.new("PayPal:", "Here is your transfer. Ready to send it?", "Misc#ident", true)
		object.views << SiriAnswerSnippet.new([answer], confirmationOptions)

		object.to_hash
  end
  
  # This gets called every time an object is received from the Guzzoni server
  def object_from_guzzoni(object, connection) 
    object
  end

  # This gets called every time an object is received from an iPhone
  def object_from_client(object, connection)
    object
  end

  # When the server reports an "unkown command", this gets called. It's useful for implementing commands that aren't otherwise covered
  def unknown_command(object, connection, command)
    # if(command.match(/test siri proxy/i))
    #   self.plugin_manager.block_rest_of_session_from_server
    # 
    #   return generate_siri_utterance(connection.lastRefId, "Siri Proxy is up and running!")   
    # end 
puts "unknown command!!"    
    respond_to(object, connection, command) 
  end

  # This is called whenever the server recognizes speech. It's useful for overriding commands that Siri would otherwise recognize
  def speech_recognized(object, connection, phrase)
    # if(phrase.match(/siri proxy map/i))
    #   self.plugin_manager.block_rest_of_session_from_server
    # 
    #   connection.inject_object_to_output_stream(object)
    # 
    #   addViews = SiriAddViews.new
    #   addViews.make_root(connection.lastRefId)
    #   mapItemSnippet = SiriMapItemSnippet.new
    #   mapItemSnippet.items << SiriMapItem.new
    #   utterance = SiriAssistantUtteranceView.new("Testing map injection!")
    #   addViews.views << utterance
    #   addViews.views << mapItemSnippet
    # 
    #   connection.inject_object_to_output_stream(addViews.to_hash)
    # 
    #   requestComplete = SiriRequestCompleted.new
    #   requestComplete.make_root(connection.lastRefId)
    # 
    #   return requestComplete.to_hash  
    # end
puts "recognized command!!"      
    respond_to(object, connection, phrase)
  end
  
  def respond_to(object, connection, phrase)
    if @state == :DEFAULT
      if phrase.match /^paypal (.+)/i
        self.plugin_manager.block_rest_of_session_from_server
				@state = :CONFIRM
				@msg = $1
				return self.generate_msg_response(connection.lastRefId, $1);
      end 
    elsif @state == :CONFIRM
      if phrase.match(/yes/i)
        self.plugin_manager.block_rest_of_session_from_server
 				@state = :DEFAULT
 				## SEND MONEY!!
 				return generate_siri_utterance(connection.lastRefId, "Ok sending money.")
      elsif phrase.match(/no/i)
        self.plugin_manager.block_rest_of_session_from_server
				@state = :DEFAULT
				return generate_siri_utterance(connection.lastRefId, "Ok I won't send it.")
      else
        self.plugin_manager.block_rest_of_session_from_server
  			return generate_siri_utterance(connection.lastRefId, "Do you want me to send it?", "I'm sorry. I don't understand. Do you want me to send it? Say yes or no.", true)
      end  
    end   

    object
   end 
end