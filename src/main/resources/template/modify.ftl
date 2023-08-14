<template>
  <c-modal
    ref="modalRef"
    v-model:visible="modalState.visible"
    width="600px"
    :title="modalState.title"
    :okText="modalState.okText"
    @ok="methods.onSubmit"
  >
    <a-form
      ref="formRef"
      name="formName"
      :model="formState"
      :rules="rules"
      autocomplete="off" layout="vertical"
    >
      <div class="grid grid-cols-2 gap-x-20px">
<#list columnList as column>
        <a-form-item label="${column.columnComment}" name="${column.columnName}">
          <a-input v-model:value="formState.${column.columnName}" placeholder="请输入${column.columnComment}..."></a-input>
        </a-form-item>
</#list>
      </div>
    </a-form>
  </c-modal>
</template>

<script setup>
import axios, { queryDetail } from '@/api';
import { message } from 'ant-design-vue';
import { required } from 'cyber-web-ui';
const formRef = ref(); // 表单ref
// 弹窗信息
const modalState = reactive({
  visible: false,
  isCreate: true,
  title: computed(() => modalState.isCreate ? '新建' : '编辑'),
  okText: computed(() => modalState.isCreate ? '新建' : '确定'),
});
// 表单信息
const formState = reactive({
<#list columnList as column>
  ${column.columnName}: undefined,
</#list>
});
// 表单校验规则
const rules = {
<#list columnList as column>
  ${column.columnName}: required(),
</#list>
};
const $emit = defineEmits(['ok']);
const methods = {
  async showModal(record) {
    modalState.visible = true;
    modalState.isCreate = !record?.id;
    let detail = await queryDetail('${classname}', record);
    Object.keys(formState).forEach(key => {
      formState[key] = detail[key];
    });
    nextTick(unref(formRef)?.clearValidate);
  },
  onSubmit() {
    return new Promise(async (resolve, reject) => {
      try {
        // 校验表单
        await unref(formRef).validate();
        // 请求添加/修改接口
        let res = await axios.request({
          url: '${classname}',
          method: modalState.isCreate ? 'post' : 'put',
          data: formState
        });
        message.success(res.message);
        $emit('ok');
        resolve();
      } catch (error) {
        console.log('error', error);
        reject();
      }
    })
  },
};

defineExpose({
  showModal: methods.showModal,
});
</script>

<style lang="less" scoped>
</style>
