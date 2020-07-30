# This blend file should be in the root directory of the Godot project. Scene Collection represents the root
# directory (i.e. res://)mof the Godot project. The subdirectories represent subdirectories in the project.
# Models will be exported to the corresponding directory, for example Scene Collection/rooms/cyberspace/common/door
# will be exported to res://rooms/cyberspace/common/door/model in the Godot project.
# NOTE: Because collection names in blender must be unique, collections with duplicate names may have a suffix
# (e.g. consumables.001). This will be stripped from the path name.

# Collection name suffixes:
#     -meshlib:
#         The collection can contain multiple meshes which will be used to create a MeshLibrary for use with
#         GridMap in Godot.
#
#     -noexp:
#         The collection will be skipped and not exported.


import os
import re
import bpy


#################################################################################
# This section's code from https://blender.stackexchange.com/a/146713 by ackh,  #
# released under CC-BY-SA 4.0. It has been modified slightly from the original. #
                                                                                #
def get_parent_collection_names(collection, parent_names):                      #
  for parent_collection in bpy.data.collections:                                #
    if collection.name in parent_collection.children.keys():                    #
      name = re.sub('\.\d+$', '', parent_collection.name)                       #
      parent_names.append(name)                                                 #
      get_parent_collection_names(parent_collection, parent_names)              #
      return                                                                    #
                                                                                #
                                                                                #
def turn_collection_hierarchy_into_path(obj):                                   #
  parent_collection = obj.users_collection[0]                                   #
  parent_names      = []                                                        #
  parent_names.append(parent_collection.name)                                   #
  get_parent_collection_names(parent_collection, parent_names)                  #
  parent_names.reverse()                                                        #
  return os.path.join(*parent_names)                                            #
                                                                                #
#################################################################################

res_path = os.path.dirname(bpy.data.filepath)

# Export each collection to a seperate .glb file.
for collection in bpy.data.collections:
    if re.sub('\.\d+$', '', collection.name).endswith("-noexp"):
        continue
    
    is_meshlib = collection.name.endswith("-meshlib")
    export_filepath = os.path.join(os.path.dirname(bpy.data.filepath), 'exports', collection.name + '.glb')
    
    # Deselect all.
    bpy.ops.object.select_all(action='DESELECT')
    
    # Select the root object in the collection.
    root_objects = [object for object in collection.objects if object.parent == None]
    
    # If we have more than root object, there are going to be problems when we try moving
    # things to world origin.
    if len(root_objects) > 1 and not is_meshlib:
        raise Exception(f'Unexpected number root objects in collection \'{collection.name}\'')
    elif len(root_objects) < 1:
        continue
    
    export_directory = os.path.join(res_path, turn_collection_hierarchy_into_path(root_objects[0]), 'models')
    
    if is_meshlib:
        export_directory = re.sub('-meshlib', '', export_directory)
    
    if not os.path.exists(export_directory):
        os.makedirs(export_directory)
    
    export_filepath = os.path.join(export_directory, re.sub('\.\d+$', '', collection.name) + '.glb')
    export_filepath = re.sub('-meshlib.glb$', '.glb', export_filepath)
    
    # Move objects to world origin in preparation for export.
    # Record the original translation so we can move it back after export.
    original_translations = []
    for i in range(len(collection.objects) if is_meshlib else 1):
        original_translations.append(root_objects[i].matrix_world.translation.copy())
        root_objects[i].matrix_world.translation = (0, 0, 0)
    
    # Select all objects in the collection.
    for object in collection.objects:
        object.select_set(True)

    # Export glTF 2.0.
    bpy.ops.export_scene.gltf(export_copyright="Copyright (c) 2020 Leroy Hopson",
            use_selection=True, filepath=export_filepath, check_existing=False)


    # Deselect all
    bpy.ops.object.select_all(action='DESELECT')

    # Move objects back to their original position.
    for i in range(len(collection.objects) if is_meshlib else 1):
        root_objects[i].matrix_world.translation = original_translations[i]
