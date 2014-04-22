module AcceptancesHelper
	def item_errors(item)
	  message = "<div>
		    	  <div>
			        #{ raw t('errors.template.header', 
			       	         count: item.errors.count,
			                 model: t('activerecord.models.item')) }
			      </div>
	              <ul>"
      item.errors.full_messages.each do |m|
        message << "<li>#{ raw m }</li>"
      end
	  message << "</ul></div>"      
      message.html_safe
	end
end
