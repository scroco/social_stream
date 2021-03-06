# The {ActivityObject} is any object that receives actions. Examples are
# creating post, liking a comment, contacting a user. 
#
# = ActivityObject subtypes
# All post, comment and user are {SocialStream::Models::Object objects}.
# Social Stream privides 3 {ActivityObject} subtypes, {Post}, {Comment} and
# {Actor}. The application developer can define as many {ActivityObject} subtypes
# as required.
# Objects are added to +config/initializers/social_stream.rb+
#
class ActivityObject < ActiveRecord::Base
  # See {SocialStream::Models::Channeled}
  channeled

  # ActivityObject is a supertype of SocialStream.objects
  supertype_of :object

  acts_as_taggable

  has_many :activity_object_activities, :dependent => :destroy
  has_many :activities, :through => :activity_object_activities

  has_many :received_actions,
           :class_name => "ActivityAction",
           :dependent  => :destroy
  has_many :followers,
           :through => :received_actions,
           :source  => :actor,
           :conditions => { 'activity_actions.follow' => true }

  has_many :activity_object_properties,
           :dependent => :destroy
  has_many :object_properties,
           :through => :activity_object_properties,
           :source => :property
  has_many :activity_object_holders,
           :class_name  => "ActivityObjectProperty",
           :foreign_key => :property_id,
           :dependent   => :destroy
  has_many :object_holders,
           :through => :activity_object_holders,
           :source  => :activity_object

  validates_presence_of :object_type

  scope :authored_by, lambda { |subject|
    joins(:channel).merge(Channel.authored_by(subject))
  }

  # The object of this activity object
  def object
    subtype_instance.is_a?(Actor) ?
      subtype_instance.subject :
      subtype_instance
  end

  # The activity in which this activity_object was created
  def post_activity
    activities.includes(:activity_verb).where('activity_verbs.name' => 'post').first
  end

  # Does this {ActivityObject} has {Actor}?
  def acts_as_actor?
    object_type == "Actor"
  end

  # Return the {Action} model to an {Actor}
  def action_from(actor)
    received_actions.sent_by(actor).first
  end

end
