class DeliveriesController < ApplicationController
  # GET /deliveries
  # GET /deliveries.xml
  require "prawn/measurement_extensions"
  prawnto :prawn => { :left_margin => 0.18.in, :right_margin => 0.18.in}

  def index

    if !params[:farm_id]
      redirect_to root_path
      return
    end

    @deliveries = Delivery.find_all_by_farm_id(params[:farm_id])
    @farm = Farm.find(params[:farm_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deliveries }
    end
  end

  # GET /deliveries/1
  # GET /deliveries/1.xml
  def show
    @delivery = Delivery.find(params[:id])


    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @delivery }
      format.csv do
        csv_string = deliveryExporter.get_csv(@delivery, params[:tabs])

        send_data csv_string,
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{@delivery.date}#{@delivery.name}.csv"
      end
      format.pdf {render :layout => false}
    end
  end

  def show_sheet
    @delivery = Delivery.find(params[:id])
  end

  def edit_order_totals
    @delivery = Delivery.find(params[:id])
  end

  # GET /deliveries/new
  # GET /deliveries/new.xml
  def new
    @delivery = Delivery.new_from_farm(@farm)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @delivery }
    end
  end

  # GET /deliveries/1/edit
  def edit
    @delivery = Delivery.find(params[:id])
  end

  # POST /deliveries
  # POST /deliveries.xml
  def create
    @delivery = Delivery.new(params[:delivery])

    respond_to do |format|
      if @delivery.save
        flash[:notice] = 'Delivery was successfully created.'
        format.html { redirect_to :action => "show", :id => @delivery.id, :farm_id => @farm.id }
        format.xml  { render :xml => @delivery, :status => :created, :location => @delivery }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @delivery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deliveries/1
  # PUT /deliveries/1.xml
  def update
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      if @delivery.update_attributes(params[:delivery])
        flash[:notice] = 'Delivery was successfully updated.'
        format.html { redirect_to :action => "show", :id => @delivery.id, :farm_id => @farm.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @delivery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.xml
  def destroy
    @delivery = Delivery.find(params[:id])
    @delivery.destroy

    respond_to do |format|
      format.html { redirect_to(@farm) }
      format.xml  { head :ok }
    end
  end
end