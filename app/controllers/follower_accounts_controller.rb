# frozen_string_literal: true

class FollowerAccountsController < ApplicationController
  include AccountControllerConcern
  include SignatureVerification

  before_action :require_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_cache_headers

  def index
    respond_to do |format|
      format.html do
        use_pack 'public'
        expires_in 0, public: true unless user_signed_in?

        next if @account.user_hides_network?

        follows
        @relationships = AccountRelationshipsPresenter.new(follows.map(&:account_id), current_user.account_id) if user_signed_in?
      end

      format.json do
        raise Mastodon::NotPermittedError if page_requested? && @account.user_hides_network?

        expires_in(page_requested? ? 0 : 3.minutes, public: public_fetch_mode?)

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def follows
    @follows ||= Follow.where(target_account: @account).recent.page(params[:page]).per(FOLLOW_PER_PAGE).preload(:account)
  end

  def page_requested?
    params[:page].present?
  end

  def page_url(page)
    account_followers_url(@account, page: page) unless page.nil?
  end

  def collection_presenter
    options = { type: :ordered }
    options[:size] = @account.followers_count unless Setting.hide_followers_count || @account.user&.setting_hide_followers_count
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: account_followers_url(@account, page: params.fetch(:page, 1)),
        items: follows.map { |f| ActivityPub::TagManager.instance.uri_for(f.account) },
        part_of: account_followers_url(@account),
        next: page_url(follows.next_page),
        prev: page_url(follows.prev_page),
        **options
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: account_followers_url(@account),
        first: page_url(1),
        **options
      )
    end
  end
end
