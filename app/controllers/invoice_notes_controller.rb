class InvoiceNotesController < ApplicationController
  # GET /invoice_notes
  # GET /invoice_notes.xml
  def index
    @invoice = Invoice.find( params[:invoice_id])
    @invoice_notes = InvoiceNote.all( :conditions => { :invoice_id => @invoice })

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoice_notes }
    end
  end

  # GET /invoice_notes/1
  # GET /invoice_notes/1.xml
  def show
    @invoice_note = InvoiceNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice_note }
    end
  end

  # GET /invoice_notes/new
  # GET /invoice_notes/new.xml
  def new
    @invoice = Invoice.find( params[:invoice_id])
    @invoice_note = @invoice.notes.new( :created_by => current_user.id, :updated_by => current_user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice_note }
    end
  end

  # GET /invoice_notes/1/edit
  def edit
    @invoice_note = InvoiceNote.find(params[:id])
  end

  # POST /invoice_notes
  # POST /invoice_notes.xml
  def create
    @invoice_note = InvoiceNote.new(params[:invoice_note])

    respond_to do |format|
      if @invoice_note.save
        @invoice = @invoice_note.invoice
        flash[:notice] = 'InvoiceNote was successfully created.'
        format.html { redirect_to( :controller => 'invoice_notes', :invoice_id => @invoice) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /invoice_notes/1
  # PUT /invoice_notes/1.xml
  def update
    @invoice_note = InvoiceNote.find(params[:id])

    respond_to do |format|
      if @invoice_note.update_attributes(params[:invoice_note])
        flash[:notice] = 'InvoiceNote was successfully updated.'
        format.html { redirect_to(@invoice_note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_notes/1
  # DELETE /invoice_notes/1.xml
  def destroy
    @invoice_note = InvoiceNote.find(params[:id])
    @invoice_note.destroy

    respond_to do |format|
      flash[:notice] = "Invoice note '#{@invoice_note.description}' was deleted"
      format.html { redirect_to( :controller => 'invoice_notes', :invoice_id => @invoice_note.invoice) }
      format.xml  { head :ok }
    end
  end
end
