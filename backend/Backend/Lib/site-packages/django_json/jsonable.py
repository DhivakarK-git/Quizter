
import json
import datetime

from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.db.utils import IntegrityError
import django.db.models.fields.files
from django.db.models import (
    Model,
    # Model Types
    # docs: https://docs.djangoproject.com/en/dev/ref/models/fields/#lowercasename
    BooleanField, #
    NullBooleanField, #
    CommaSeparatedIntegerField, #
    EmailField, # max_length
    IPAddressField, #
    GenericIPAddressField, #
    URLField, # max_length=200
    FileField, # upload_to max_length=100
    ImageField, # upload_to max_length=100
    CharField, # max_length
    TextField, #
    DateField, # auto_now=False auto_now_add=False
    DateTimeField, # auto_now=False auto_now_add=False
    TimeField, # auto_now=False auto_now_add=False
    BigIntegerField, #
    DecimalField, # max_digits decimal_places
    FloatField,
    IntegerField,
    PositiveIntegerField,
    PositiveSmallIntegerField,
    SmallIntegerField,
    ForeignKey, #(Other) # Use a string name if Other is not yet defined.
    ManyToManyField, #(Other)
    OneToOneField, #(Other) # You need only specify one side of the relationship.
    ManyToManyRel,
)

# In Postgres, sometimes objects returned by "[model]_set" aren't ordered
# according to Model.Meta.ordering.
def order_by_default(query):
    if hasattr(query.model, 'Meta') and \
       hasattr(query.model.Meta, 'ordering') and \
       0 < len(query.model.Meta.ordering):
        return query.order_by(*query.model.Meta.ordering)
    else:
        return query

class JSONable:
    @classmethod
    def from_json_dict(
            cls, 
            dictionary, 
            json_attributes = None,
            whitelist = [],
            blacklist = []):

        if json_attributes == None:
            json_attributes = cls.json_attributes
        json_attributes = list(
            set(json_attributes).union(set(whitelist)) - 
            set(blacklist))
        foreign_keys = {}
        attributes = {}
        for key in json_attributes:
            if key[-4:] == '_set' and \
               key[:-4] + 's' in dictionary:
                key_name = key[:-4] + 's'
                foreign_keys[key] = (cls.__dict__[key].rel, dictionary[key_name])
            if key in dictionary or \
               (key[-5:] == '_json' and 
                key[:-5] in dictionary):

                if key[-5:] == '_json':
                    key_name = key[:-5]
                    attributes[key_name + '_json_string'] = json.dumps(dictionary[key_name])
                else:
                    attributes[key] = dictionary[key]

        # Create model
        try:
            model = cls.objects.get(id = attributes['id'])
            cls.objects.filter(id = attributes['id']).update(**attributes)
            model = cls.objects.get(id = attributes['id'])
        except KeyError:
            if cls == User and 'username' in attributes:
                try:
                    model = cls.objects.get(username = attributes['username'])
                except ObjectDoesNotExist:
                    model = cls(**attributes)
                    model.save()
            else:
                model = cls(**attributes)
                model.save()
        except ObjectDoesNotExist:
            model = cls(**attributes)
            model.save()

        # Add relationships
        for key in foreign_keys:
            (rel, related_model_jsons) = foreign_keys[key]
            if type(rel) is ManyToManyRel:
                RelatedModel = rel.model
            else:
                RelatedModel = rel.related_model
            related_models = [
                RelatedModel.from_json_dict(model_json)
                for model_json in related_model_jsons]
            getattr(model, key).set(related_models)
        return model

    def as_json_dict(
            self, 
            json_attributes = None,
            whitelist = [],
            blacklist = [],
            include_deleted = False):
        if json_attributes == None:
            json_attributes = self.json_attributes
        json_attributes = list(
            set(json_attributes).union(set(whitelist)) - 
            set(blacklist))
        dictionary = {}
        for key in json_attributes:
            if key[-4:] == '_set':
                objects = order_by_default(getattr(self, key))
                if include_deleted:
                    all_objects = objects.all()
                else:
                    if hasattr(objects.model, 'deleted'):
                        objects = objects.filter(deleted = False)
                    all_objects = objects.all()
                dictionary[key[:-4] + 's'] = list(map(
                    (lambda thing: thing.as_json_dict(
                        include_deleted = include_deleted)),
                    all_objects))
            else:
                if key[-5:] == '_json':
                    key_name = key[:-5]
                    dictionary[key_name] = \
                        json.loads(self.__dict__[key_name + '_json_string'])
                else:
                    dictionary[key] = getattr(self, key)

                    if isinstance(dictionary[key], Model):
                        dictionary[key] = \
                            dictionary[key].as_json_dict()

                    if isinstance(
                        dictionary[key],
                        django.db.models.fields.files.ImageFieldFile):
                        
                        file = dictionary[key]
                        del dictionary[key]
                        if file and hasattr(file, 'url'):
                            dictionary[key + '_url'] = file.url
                        else:
                            dictionary[key + '_url'] = None
        
        # Convert datetimes to strings
        for attribute in dictionary.keys():
            if dictionary[attribute].__class__ == datetime.datetime:
                dictionary[attribute] = str(dictionary[attribute])
        
        return dictionary
    
    def as_json(
            self, 
            json_attributes = None,
            whitelist = [],
            blacklist = [],
            include_deleted = False):
        dictionary = self.as_json_dict(
            json_attributes,
            whitelist,
            blacklist,
            include_deleted)
        return json.dumps(dictionary)
    
    @classmethod
    def all_as_json_dicts(
            self,
            json_attributes = None,
            whitelist = [],
            blacklist = [],
            include_deleted = False):
        if include_deleted or not hasattr(self, 'undeleted'):
            objects = order_by_default(self.objects).all()
        else:
            objects = order_by_default(self.undeleted()).all()
        return [ 
            jsonable.as_json_dict(
                json_attributes,
                whitelist,
                blacklist,
                include_deleted)
            for jsonable in objects ]
    
    @classmethod
    def all_as_json(
            self,
            json_attributes = None,
            whitelist = [],
            blacklist = [],
            include_deleted = False):
        return json.dumps(self.all_as_json_dicts(
            json_attributes, 
            whitelist, 
            blacklist,
            include_deleted))

    @classmethod
    def rename_keys(self, thing, rename):
        if type(thing) == dict:
            return {
                rename(key): self.rename_keys(thing[key], rename)
                for key in thing
            }
        elif type(thing) == list:
            return [
                self.rename_keys(item, rename)
                for item in thing ]
        else:
            return thing

def filter_ids(thing):
    if type(thing) == list:
        return list(map(filter_ids, thing))
    elif type(thing) == dict:
        return {
            key: filter_ids(thing[key])
            for key in thing
            if key[-3:] != '_id' and key != 'id'
        }
    else:
        return thing

def copy(model):
    return type(model).from_json_dict(filter_ids(model.as_json_dict()))

def copies(models):
    return list(map(copy, models))
