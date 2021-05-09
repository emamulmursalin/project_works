"""
The dataset used here is downloaded from Kaggle using following link:
https://www.kaggle.com/crowww/a-large-scale-fish-dataset

The credit of this dataset goes to:
O.Ulucan , D.Karakaya and M.Turkan.(2020) A large-scale dataset for fish segmentation and classification.
In Conf. Innovations Intell. Syst. Appli. (ASYU)
"""

import tensorflow as tf
import PIL
import glob
import matplotlib.pyplot as plt
import random
import keras

from tensorflow.keras import layers, models, optimizers, losses, activations

import pathlib
import os

# Setting the base directory and finding the number of images
base_dir = 'C:/Users/emamu/Downloads/Fish_Dataset_NA'
base_dir = pathlib.Path(base_dir)
print('Name of the fishes:', os.listdir(base_dir))
print('Total number of images:', len(list(base_dir.glob('*/*.PNG'))))
print('Number of images of {} fish is:'.format(os.listdir(base_dir)[0]), len((list(base_dir.glob('Black Sea Sprat/*.png')))))


# Separating training and validation data
img_height = 250 #1024
img_width = 250 #768
batch_size = 30

training_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    base_dir, validation_split=0.2,
    subset='training', seed=123,
    image_size=(img_height, img_width), batch_size=batch_size)

validation_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    base_dir, validation_split=0.2,
    subset='validation', seed=123,
    image_size=(img_height,img_width), batch_size=batch_size)

class_names = training_dataset.class_names

for image_batch, label_batch in training_dataset:
    print(image_batch.shape)
    print(label_batch.shape)
    break

# Creating the CNN model

normalizing_layer = layers.experimental.preprocessing.Rescaling(1./255, input_shape=(img_height, img_width, 3))
augmentation_layer = tf.keras.Sequential([layers.experimental.preprocessing.RandomFlip('horizontal_and_vertical',
                                                                                   input_shape=(img_height, img_width, 3)),
                                      layers.experimental.preprocessing.RandomRotation(0.1),
                                      layers.experimental.preprocessing.RandomZoom(0.1)])

model = models.Sequential()
model.add(augmentation_layer)
model.add(normalizing_layer)
model.add(layers.Conv2D(8, (3,3),  activation=activations.relu, padding='same'))
model.add(layers.MaxPooling2D(2,2))
model.add(layers.Conv2D(16, (3,3),  activation=activations.relu, padding='same'))
model.add(layers.MaxPooling2D(2,2))
model.add(layers.Conv2D(32, (3,3),  activation=activations.relu, padding='same'))
model.add(layers.MaxPooling2D(2,2))
model.add(layers.Conv2D(64, (3,3),  activation=activations.relu, padding='same'))
model.add(layers.MaxPooling2D(2,2))
# model.add(layers.Conv2D(128, (3,3),  activation=activations.relu, padding='same'))
# model.add(layers.MaxPooling2D(2,2))

model.add(layers.Flatten())
model.add(layers.Dense(256, activation=activations.relu))
model.add(layers.Dropout(0.2))
model.add(layers.Dense(128, activation=activations.relu))
model.add(layers.Dropout(0.2))
model.add(layers.Dense(9, activation=activations.softmax))

model.compile(optimizer= optimizers.Adam(), loss=losses.sparse_categorical_crossentropy, metrics=['accuracy'])
model.summary()


history = model.fit(training_dataset, validation_data=validation_dataset, epochs=20)
