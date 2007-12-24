class StepsController < ApplicationController
  # GET /steps
  # GET /steps.xml
  def index
    @steps = Step.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @steps.to_xml }
    end
  end

  # GET /steps/1
  # GET /steps/1.xml
  def show
    @step = Step.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @step.to_xml }
    end
  end

  # GET /steps/new
  def new
    @step = Step.new
  end

  # GET /steps/1;edit
  def edit
    @step = Step.find(params[:id])
  end

  # POST /steps
  # POST /steps.xml
  def create
    @step = Step.new(params[:step])

    respond_to do |format|
      if @step.save
        flash[:notice] = 'Step was successfully created.'
        format.html { redirect_to step_url(@step) }
        format.xml  { head :created, :location => step_url(@step) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @step.errors.to_xml }
      end
    end
  end

  # PUT /steps/1
  # PUT /steps/1.xml
  def update
    @step = Step.find(params[:id])

    respond_to do |format|
      if @step.update_attributes(params[:step])
        flash[:notice] = 'Step was successfully updated.'
        format.html { redirect_to step_url(@step) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @step.errors.to_xml }
      end
    end
  end

  # DELETE /steps/1
  # DELETE /steps/1.xml
  def destroy
    @step = Step.find(params[:id])
    @step.destroy

    respond_to do |format|
      format.html { redirect_to steps_url }
      format.xml  { head :ok }
    end
  end
end
