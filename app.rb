$KCODE = 'u'
require 'jcode'

require 'thread'
require 'rubygems'
require 'sinatra'
require 'system_timer'
require 'benchmark'
require 'active_record'
require './models/sqassignments.rb'

class App < Sinatra::Application

  #list all SQ Assignments
  get '/sqassignments' do   
    @sqa = Sqassignments.all
    #@sqa = Paises.all#.first
    #@sqa.map{|m| m.st_descripcion.to_s + "<br>"}
    #@sqa.map{|m| m.id.to_s + "<br>"}
    @sqas = Sqassignmentstatu.all
    haml :sqassignments_list, :locals => {:sqassignments => @sqa, :sqastatus => @sqas}
  end

  #form for new SQ Assignment
  get '/sqassignments/new' do
    @user_email = request.cookies['km_ni']
    @user_email2 = request.cookies['km_ai']
    #Usuarios.public_methods.join("<br/>\n")
    #Usuarios.find('19061936').usu_email.to_s
    @user_codusuario = Usuarios.find_by_usu_email(@user_email).usu_codusuario.to_s
    @sqas = Sqassignmentstatu.all
    haml :sqassignment_new, :locals => {:user_email => @user_email, :user_codusuario => @user_codusuario, :sqastatus => @sqas}
  end

  get '/sqassignments/view/:id' do
    @sqa = [Sqassignments.find_by_id(params[:id])]
    haml :sqassignments_list, :locals => {:sqassignments => @sqa}
  end


  #create new SQ Assignment
  post '/sqassignments/new' do
    #insert en sqassignments
    @sqa = Sqassignments.new(:url_busqueda => params[:url_busqueda], :usuario_id => params[:usuario_id], :t_assigned => Time.now, :status_id => params[:status_id])
    @sqa.save
    haml :sqassignment_created, :locals => {:url_busqueda => params[:url_busqueda]}
  end

end
