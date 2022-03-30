import 'package:injector/injector.dart';
import 'package:serializable_data/serializable_data.dart';

void registerDataDependencies() {
  Injector.appInstance.registerDependency<Tag>(() => Tag());
  Injector.appInstance.registerDependency<Artefact>(() => Artefact());
  Injector.appInstance.registerDependency<UrlNotes>(() => UrlNotes());
}

Map<String, String> dataText = {
  Tag.nameLabel: 'Tag',
  Tag.tagNameErrorLabel: 'Please provide a Tag name with at least 3 characters',
  Tag.duplicateTagError: 'A tag with this name already exists'
};

Map<String, DataSpecification> dataSpecification() {
  var specifications = <String, DataSpecification>{};

  specifications[Tag.nameLabel] = DataSpecification(
      label: 'Tag Name',
      help: 'Add a new Tag to label your files',
      type: DataSpecification.textType,
      validator: (value) {
        if ((value ?? '').isEmpty) {
          return Tag.tagNameErrorLabel;
        } else {
          if (value.length < 4) {
            return Tag.tagNameErrorLabel;
          } else {
            return null;
          }
        }
      });

  specifications[Artefact.nameLabel] = DataSpecification(type: DataSpecification.textType);
  specifications[Artefact.tagsLabel] = DataSpecification(type: DataSpecification.listType);

  return specifications;
}

Map<String, RelationshipSpecification> relationshipSpecification = <String, RelationshipSpecification>{

};

class Tag extends PersistableDataObject {
  static const String tagNameErrorLabel = 'tagNameError';
  static const String duplicateTagError = 'duplicateTagError';
  static const String nameLabel = 'name';


  static const String objectType = 'Tag';
  Tag({Map<String, dynamic>? data}) : super(objectType);
}

class Artefact extends PersistableDataObject {
  static const String objectType = 'Artefact';

  static const String nameLabel = 'artefactName';
  static const String tagsLabel = 'tags';

  Artefact() : super(objectType);

  void addTag(String tag) {
    List list = get(tagsLabel) ?? <String>[];
    if (!list.contains(tag)) {
      list.add(tag);
      set(tagsLabel, list);
    }
  }

}

class UrlNotes extends PersistableDataObject {
  static const String objectType = 'UrlNotes';

  static const String urlLabel = 'url';
  static const String commentLabel = 'comment';
  static const String hashLabel = 'hash';

  UrlNotes() : super(objectType);


}