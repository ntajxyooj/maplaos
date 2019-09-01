<?php
// This class was automatically generated by a giiant build task
// You should not change it manually as it will be overwritten on next build

namespace app\models\base;

use Yii;

/**
 * This is the base-model class for table "photo".
 *
 * @property integer $id
 * @property string $photo
 * @property integer $location_details_id
 *
 * @property \app\models\LocationDetails $locationDetails
 * @property string $aliasModel
 */
abstract class Photo extends \yii\db\ActiveRecord
{



    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'photo';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['photo', 'location_details_id'], 'required'],
            [['photo'], 'string'],
            [['location_details_id'], 'integer'],
            [['location_details_id'], 'exist', 'skipOnError' => true, 'targetClass' => \app\models\LocationDetails::className(), 'targetAttribute' => ['location_details_id' => 'id']]
        ];
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'photo' => 'Photo',
            'location_details_id' => 'Location Details ID',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getLocationDetails()
    {
        return $this->hasOne(\app\models\LocationDetails::className(), ['id' => 'location_details_id']);
    }




}
