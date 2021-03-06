/* Simple Accordion Script 
 * Requires Prototype and Script.aculo.us Libraries
 * By: Brian Crescimanno <brian.crescimanno@gmail.com>
 * http://briancrescimanno.com
 * This work is licensed under the Creative Commons Attribution-Share Alike 3.0
 * http://creativecommons.org/licenses/by-sa/3.0/us/
 */

if (typeof Effect == 'undefined')
  throw("You must have the script.aculo.us library to use this accordion");

var Accordion = Class.create({

    initialize: function(id, steps) {
        if(!$(id)) throw("Attempted to initalize accordion with id: "+ id + " which was not found.");
        this.accordion = $(id);
        this.options = {
            toggleClass: "accordion-toggle",
            toggleActive: "accordion-toggle-active",
            contentClass: "accordion-content"
        }
				this.step_ids = steps;
				this.index = 0;
        this.contents = this.accordion.select('div.'+this.options.contentClass);
        this.isAnimating = false;
        this.maxHeight = 0;
        this.current = this.contents[this.index];
				this.currentAllowClicks = true;
        this.toExpand = null;

        this.checkMaxHeight();
        this.initialHide();
        this.attachInitialMaxHeight();
				this.current_step_id = this.step_ids[0];
        var clickHandler =  this.clickHandler.bindAsEventListener(this);
        this.accordion.observe('click', clickHandler);
    },
		start: function(){
			// this.index = 0;
			// 			this.contents[this.index].previous('div.'+this.options.toggleClass).addClassName(this.options.toggleActive);
			// 			this.expand_t(this.contents[this.index]);
			this.step(this.step_ids[0]);
		},
		get_current_step_id: function(){
			return this.current_step_id;
		},
		step: function(step_id){
			var found = false;
			for(var i = 0; i < this.step_ids.length; i++){
				if(this.step_ids[i] == step_id)
				{
					found = true;
					this.current_step_id = step_id;
					this.contents[this.index].previous('div.'+this.options.toggleClass).removeClassName(this.options.toggleActive);
					this.index = i;
					this.contents[this.index].previous('div.'+this.options.toggleClass).addClassName(this.options.toggleActive);
					this.expand_t(this.contents[this.index]);
				}
			}
			if(!found){
				this.step(this.current_step_id);
			}
		},
		
		expand_next:function(){
			for(var i=0; i<this.contents.length; i++){
		    if(this.contents[i] == this.current){
		      if(i < this.contents.length){
		        this.expand_t(this.contents[i + 1]);
		      }
		    }
		  }
		},
		expand_previous: function(){
			for(var i=0; i<this.contents.length; i++){
		    if(this.contents[i] == this.current){
		      if(i > 0){
		        this.expand_t(this.contents[i - 1]);
		      }
		    }
		  }
		},
		expand_t: function(to_expand){
			this.toExpand = to_expand;
      // if(this.current != this.toExpand){
				  this.toExpand.show();
          this.animate();
      // }
		},
    expand: function(el) {
        this.toExpand = el.next('div.'+this.options.contentClass);
        // if(this.current != this.toExpand){
						this.toExpand.show();
            this.animate();
        // }
    },

    checkMaxHeight: function() {
        for(var i=0; i<this.contents.length; i++) {
            if(this.contents[i].getHeight() > this.maxHeight) {
                this.maxHeight = this.contents[i].getHeight();
            }
        }
    },

    attachInitialMaxHeight: function() {
		// this.current.previous('div.'+this.options.toggleClass).addClassName(this.options.toggleActive);
        if(this.current.getHeight() != this.maxHeight) this.current.setStyle({height: this.maxHeight+"px"});
    },

    clickHandler: function(e) {
            var el = e.element();
            if(el.hasClassName(this.options.toggleClass) && !this.isAnimating) {
							if(el.next('div.'+this.options.contentClass) == this.current && !this.currentAllowClicks){
								this.currentAllowClicks = true;
								el.next('div.'+this.options.contentClass).hide();
							}else{
								this.currentAllowClicks = false;
                this.expand(el);
							}
            }
        },

    initialHide: function(){
        for(var i=0; i<this.contents.length; i++){
            // if(this.contents[i] != this.current) {
                this.contents[i].hide();
                this.contents[i].setStyle({height: 0});
            // }
        }
    },

    animate: function() {
        var effects = new Array();
        var options = {
            sync: true,
            scaleFrom: 0,
            scaleContent: false,
            transition: Effect.Transitions.sinoidal,
            scaleMode: {
                originalHeight: this.maxHeight,
                originalWidth: this.accordion.getWidth()
            },
            scaleX: false,
            scaleY: true
        };

        effects.push(new Effect.Scale(this.toExpand, 100, options));

        options = {
            sync: true,
            scaleContent: false,
            transition: Effect.Transitions.sinoidal,
            scaleX: false,
            scaleY: true
        };
				if(this.current != this.toExpand){
					effects.push(new Effect.Scale(this.current, 0, options));
				}
        

        var myDuration = 0.75;

        new Effect.Parallel(effects, {
            duration: myDuration,
            fps: 35,
            queue: {
                position: 'end',
                scope: 'accordion'
            },
            beforeStart: function() {
                this.isAnimating = true;
								// if(this.current != this.toExpand){
								// 									this.current.previous('div.'+this.options.toggleClass).removeClassName(this.options.toggleActive);
								// 									// this.toExpand.previous('div.'+this.options.toggleClass).addClassName(this.options.toggleActive);
								// 								}                
                
            }.bind(this),
            afterFinish: function() {
								if(this.current != this.toExpand){
	                this.current.hide();
								}
                this.toExpand.setStyle({ height: this.maxHeight+"px" });
                this.current = this.toExpand;
                this.isAnimating = false;
            }.bind(this)
        });
    }

});
