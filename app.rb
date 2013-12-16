$KCODE = 'u'
require 'jcode'

require 'thread'
require 'rubygems'
require 'sinatra'
require 'system_timer'
require 'benchmark'
require 'active_record'
require 'haml'
require './models/sqassignments.rb'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/view_helpers/sinatra'

class App < Sinatra::Application

  #get the id of the SQAssignmentStatus "Finished"
  def get_finished_status_id
    @sqas = Sqreview.find_by_sql(" SELECT * FROM sqassignmentstatus WHERE description = 'Finalizado' ")
    @sqas.first.id
  end
  
  #is the assignment completed?
  def is_completed?(assignment)
    !assignment.first.t_completed.nil?
  end

  #list all SQ Assignments
  get '/sqassignments' do   
    @sqa = Sqassignments.paginate(:page => params[:page], :per_page => 20)
    @sqas = Sqassignmentstatu.all
    haml :sqassignments_list, :locals => {:sqassignments => @sqa, :sqastatus => @sqas}
  end

  #form for new SQ Assignment
  get '/sqassignments/new' do
    @user_email = request.cookies['km_ni']
    @user_email2 = request.cookies['km_ai']
    @user_codusuario = Usuarios.find_by_usu_email(@user_email).usu_codusuario.to_s
    @sqas = Sqassignmentstatu.all
    haml :sqassignment_new, :locals => {:user_email => @user_email, :user_codusuario => @user_codusuario, :sqastatus => @sqas}
  end
  #create new SQ Assignment
  post '/sqassignments/new' do
    #insert en sqassignments
    @sqa = Sqassignments.new(:url_busqueda => params[:url_busqueda], :usuario_id => params[:usuario_id], :t_assigned => Time.now, :status_id => params[:status_id])
    @sqa.save
    haml :sqassignment_created, :locals => {:url_busqueda => params[:url_busqueda]}
  end

  #view an assignment
  get '/sqassignments/view/:id' do
    @sqa = [Sqassignments.find_by_id(params[:id])]
    @sqas = Sqassignmentstatu.all
    @sqarc = Sqreviewclasse.all
    @sqar = Sqreview.find_by_sql(" SELECT * FROM sqreviews WHERE sq_assignment_id = #{params[:id]}")
    b_completed = is_completed?(@sqa)
    haml :sqassignments_list, :locals => {:sqassignments => @sqa, :sqastatus => @sqas, :sqscores => @sqarc, :sqreviews => @sqar, :b_completed => b_completed}
  end

  #form to modify the url or status of an assignment
  get '/sqassignments/edit/:id' do
    @sqa = [Sqassignments.find_by_id(params[:id])]
    @sqas = Sqassignmentstatu.all
    @user_email = request.cookies['km_ni']
    @user_email2 = request.cookies['km_ai']
    @user_codusuario = Usuarios.find_by_usu_email(@user_email).usu_codusuario.to_s
    haml :sqassignment_edit, :locals => {:sqassignments => @sqa, :sqastatus => @sqas, :user_email => @user_email, :user_codusuario => @user_codusuario}
  end
  #modify the url or status of an assignment
  post '/sqassignments/edit/:id' do
    @sqa_old = [Sqassignments.find_by_id(params[:id])]
    #params[:t_completed].nil?.to_s
    @sqas = Sqassignmentstatu.all
    #encontrar el ID del estado "finalizado"
    id_finish = @sqas.find{|x| x.description =~ /finalizado/i}.id.to_s
    b_finalizado = params[:status_id] == id_finish
    if b_finalizado #ha finalizado, cambiar t_completed
      @sqa = Sqassignments.update(params[:id], :url_busqueda => params[:url_busqueda], :t_assigned => params[:t_assigned], :t_completed => Time.now, :status_id => params[:status_id])
    else #aún no está finalizado, no hay valor para t_completed
      @sqa = Sqassignments.update(params[:id], :url_busqueda => params[:url_busqueda], :t_assigned => params[:t_assigned], :status_id => params[:status_id])
    end
    @sqa.save
    haml :sqassignment_modified, :locals => {:id => params[:id], :b_finalizado => b_finalizado}
  end

  #save a sqreview
  post '/sqassignments/new_sqreview' do
    1.upto(10){|i|
      if params["vid_#{i}"].to_i > 1
        @sqr = Sqreview.find_by_id(params["sq_review_id_#{i}"])
        #update review
        if !@sqr.nil?
          @sqr.update_attributes(:id => params["sq_review_id#{i}"], :usuario_id => params[:usuario_id], :t_completed => Time.now, :vid => params["vid_#{i}"], :sq_assignment_id => params[:sq_assignment_id], :position => params["position_#{i}"], :review_score_id => params["review_score_id_#{i}"], :user_comment => params["user_comment_#{i}"])
          @sqr.save
        #save new review
        else
          @sqr = Sqreview.new(:usuario_id => params[:usuario_id], :t_completed => Time.now, :vid => params["vid_#{i}"], :sq_assignment_id => params[:sq_assignment_id], :position => params["position_#{i}"], :review_score_id => params["review_score_id_#{i}"], :user_comment => params["user_comment_#{i}"])
          @sqr.save
        end
      end
    }

    #did we press the end button?
    if params[:end_sqreview]
      #change t_completed date, and assignment status
      id_fin = get_finished_status_id
      @sqa = Sqassignments.find_by_id(params[:sq_assignment_id])
      @sqa.update_attributes(:t_completed => Time.now, :status_id => id_fin)
      @sqa.save
    end
    
    haml :sqreview_saved, :locals => {:b_finish => @b_finish, :id => params[:sq_assignment_id]}
  end

end
