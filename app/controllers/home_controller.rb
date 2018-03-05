class HomeController < ApplicationController
  def index
  end

  def out
    @apply = Apply.where("univ LIKE ?", "#{params[:univ]}")
    @apply.destroy_all

    redirect_to "/home/index"
  end

  def list
    @apply = Apply.where("univ LIKE ?", "#{params[:univ]}")
  end

  def view
    @apply = Apply.find(params[:id])
  end

  def save_pdf
    @apply = Apply.find(params[:id])
    send_data(disposition: 'inline')
  end

  def users
    require 'rubygems'
    require 'mechanize'

    agent = Mechanize.new
    @page = agent.get('https://apply.likelion.org/users/sign_in')

    @my_page = @page.form_with(:action => '/users/sign_in') do |f|
      f.field_with(:name => 'user[email]').value = params[:email]
      f.field_with(:name => 'user[password]').value = params[:password]
      @user = User.create(email: params[:email],
                          password: params[:password])
    end.submit

    @apply_find = Apply.where("univ LIKE ?","#{params[:email]}")

    if @apply_find.count > 0
      @apply_find.destroy_all
      parse_data
    else
      parse_data
    end

    @user = User.find_by_email(params[:email])
  end

  def parse_data

    @href = []
    @my_page.links.each do |link|
      if link.href.to_s.include? ('/operator/applications/')
        @href << link.href
      end
    end
    @name = Array.new
      @my_page.search('body > div > article > ul > li > div > div:nth-child(1) > a').each do |n|
        @name << n.inner_text
      end
      @email = Array.new
      @my_page.search('body > div > article > ul > li:nth-child(n) > div > div:nth-child(2)').each do |n|
        @email << n.inner_text
      end
      @phone = Array.new
      @my_page.search('body > div > article > ul > li:nth-child(n) > div > div:nth-child(3)').each do |n|
        @phone << n.inner_text
      end
      @course = Array.new
      @my_page.search('body > div > article > ul > li:nth-child(n) > div > div:nth-child(4)').each do |n|
        @course << n.inner_text
      end
      @grade = Array.new
      @my_page.search('body > div > article > ul > li:nth-child(n) > div > div:nth-child(5)').each do |n|
        @grade << n.inner_text
      end

      (0..@href.length-1).each do |l|
        one = @my_page.link_with(:href => @href[l]).click
        @title = one.search('body > div > header > h2').map(&:text)
        @reason = one.search('#reason').map(&:text) #지원동기
        @service = one.search('#service').map(&:text) #만들고 싶은 IT서비스
        unless one.search('body > div.container > article > ul > li:nth-child(11) > h5').map(&:text).nil?
            @q1 = one.search('body > div.container > article > ul > li:nth-child(11) > h5').map(&:text) #1번 질문
            @a1 = one.search('#a1').map(&:text) #1번 답
        end

        unless one.search('body > div.container > article > ul > li:nth-child(12) > h5').map(&:text).nil? #2번 질문
          @q2 = one.search('body > div.container > article > ul > li:nth-child(12) > h5').map(&:text) #2번 질문
          @a2 = one.search('#a2').map(&:text) #2번 답
        end

        unless one.search('body > div.container > article > ul > li:nth-child(13) > h5').map(&:text).nil?
          @q3= one.search('body > div.container > article > ul > li:nth-child(13) > h5').map(&:text) #3번 질문
          @a3 = one.search('#a3').map(&:text) #3번 답
        end

        unless one.search('body > div > article > ul > li:nth-child(14) > div > a').map(&:text).join == ""
          @a4 = one.link_with(:text => "#{one.search('body > div > article > ul > li:nth-child(14) > div > a').map(&:text).join}").href
        else
          @a4 = "N"
        end #pdf 파일 첨부 확인

        @apply = Apply.new
        @apply.univ = params[:email]
        @apply.title = @title.join
        @apply.name = @name[l]
        @apply.email = @email[l]
        @apply.phone = @phone[l]
        @apply.course = @course[l]
        @apply.grade = @grade[l]
        @apply.reason = @reason.join
        @apply.service = @service.join
        @apply.q1 = @q1.join
        @apply.a1 = @a1.join

        @apply.q2 = @q2.join
        @apply.a2 = @a2.join

        @apply.q3 = @q3.join
        @apply.a3 = @a3.join

        @apply.a4 = @a4

        @apply.save
      end
    end
end
