class Relation::Public < Relation
  scope :actor, lambda { |a|
    where(:actor_id => Actor.normalize_id(a))
  }

  validates_presence_of :actor_id

  class << self
    def default_for(actor)
      create! :actor => actor
    end

    # The {Relation::Public} belonging to actor
    def of(actor)
      actor(actor).first
    end
  end

  # A {Relation::Public public relation} is always the weakest
  def <=>(relation)
    1
  end

  # The name of public relation
  def name
    I18n.t('relation_public.name')
  end

  # Are we supporting custom permissions for {Relation::Public}? Not by the moment.
  def allow?(user, action, object)
    action == 'read' && object == 'activity'
  end
end
